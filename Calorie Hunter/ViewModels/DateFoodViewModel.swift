// DateFoodViewModel.swift
import Foundation
import CoreData
import HealthKit

@MainActor
final class DateFoodViewModel: ObservableObject, FoodAddingViewModel {
    // MARK: - Published Properties
    @Published var foodEntries: [FoodItem] = []
    @Published var totalCalories: Int = 0
    @Published var totalProtein: Double = 0
    @Published var totalCarbs: Double = 0
    @Published var totalFat: Double = 0

    // Protocol requirements
    @Published var currentProduct: FoodItem?
    @Published var errorMessage: String?

    /// All foods available for search/listing (catalog + user‐saved)
    var allFoods: [FoodItem] {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntity.name, ascending: true)]
        do {
            let entities = try context.fetch(request)
            return entities.map { fe in
                FoodItem(
                    id: fe.id ?? UUID(),
                    name: fe.name ?? "",
                    calories: Int(fe.calories),
                    protein: fe.protein,
                    carbs: fe.carbs,
                    fat: fe.fat,
                    grams: fe.grams,
                    mealType: fe.mealType ?? "",
                    date: date,          // default date for new logs
                    isUserAdded: fe.isUserAdded,
                    barcode: fe.barcode
                )
            }
        } catch {
            print("Error fetching catalog foods: \(error)")
            return []
        }
    }

    // MARK: - Dependencies
    private let lastImportKey = "lastNutritionImportDate"
    private let context: NSManagedObjectContext
    let date: Date

    // MARK: - Initialization
    init(date: Date, context: NSManagedObjectContext) {
        self.date = Calendar.current.startOfDay(for: date)
        self.context = context
        loadEntries()
        
        // Figure out where to start importing
        let lastImport = UserDefaults.standard.object(forKey: lastImportKey) as? Date
        let startDate  = lastImport
        ?? Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        
        // Now only import from startDate → today
        HealthKitManager.shared.requestAuthorization { success, _ in
            guard success else { return }
            NutritionManager().updateHistoricalNutrition(startDate: startDate, endDate: Date()) {
                // Update the “last import” so we don’t refetch this again
                UserDefaults.standard.set(Date(), forKey: self.lastImportKey)
                
                // Finally, refresh today’s totals
                if let today = NutritionHistoryManager.shared.nutritionForPeriod(days: 1).first {
                    DispatchQueue.main.async {
                        self.totalCalories = Int(today.calories)
                        self.totalProtein  = today.protein
                        self.totalCarbs    = today.carbs
                        self.totalFat      = today.fat
                        self.objectWillChange.send()
                    }
                }
            }
        }
    }

    // MARK: - Loading Data
    func loadEntries() {
        let request: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ConsumptionEntity.dateEaten, ascending: true)]
        let start = date
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        request.predicate = NSPredicate(format: "dateEaten >= %@ AND dateEaten < %@", start as NSDate, end as NSDate)
        do {
            let entries = try context.fetch(request)
            self.foodEntries = entries.compactMap { entry in
                guard let fe = entry.food else { return nil }
                let factor = entry.gramsConsumed / 100.0
                return FoodItem(
                    id: entry.id ?? UUID(),
                    name: fe.name ?? "",
                    calories: Int(fe.calories * factor),
                    protein: fe.protein * factor,
                    carbs: fe.carbs * factor,
                    fat: fe.fat * factor,
                    grams: entry.gramsConsumed,
                    mealType: entry.mealType ?? "",
                    date: entry.dateEaten ?? date,
                    isUserAdded: true,
                    barcode: fe.barcode
                )
            }
            updateTotals()
        } catch {
            print("Error loading entries for date \(date):", error)
        }
    }

    // MARK: - Totals Calculation
    private func updateTotals() {
        // First, attempt to load NutritionEntry for this date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let ds = formatter.string(from: date)

        let req: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        req.predicate = NSPredicate(format: "dateString == %@", ds)

        if let hist = (try? context.fetch(req))?.first {
            // Use historical HealthKit-imported values
            totalCalories = Int(hist.calories)
            totalProtein  = hist.protein
            totalCarbs    = hist.carbs
            totalFat      = hist.fat
        } else {
            // Fallback to summing manual consumption entries
            totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
            totalProtein  = foodEntries.reduce(0) { $0 + $1.protein }
            totalCarbs    = foodEntries.reduce(0) { $0 + $1.carbs }
            totalFat      = foodEntries.reduce(0) { $0 + $1.fat }
        }
    }

    /// Returns total calories for a given meal type on this date.
    func totalCaloriesForMealType(_ mealType: String) -> Int {
        foodEntries
          .filter { $0.mealType == mealType }
          .reduce(0) { $0 + $1.calories }
    }

    // MARK: - Find / Fetch Protocol Methods
    func findFood(byBarcode code: String) -> FoodItem? {
        let req: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        req.predicate = NSPredicate(format: "barcode == %@", code)
        if let fe = try? context.fetch(req).first {
            return FoodItem(
                id: fe.id ?? UUID(),
                name: fe.name ?? "",
                calories: Int(fe.calories),
                protein: fe.protein,
                carbs: fe.carbs,
                fat: fe.fat,
                grams: fe.grams,
                mealType: fe.mealType ?? "",
                date: fe.date ?? date,
                isUserAdded: fe.isUserAdded,
                barcode: fe.barcode
            )
        }
        return nil
    }

    @MainActor
    func fetchProduct(barcode: String) async {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL for barcode \(barcode)"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ProductResponse.self, from: data)
            if let apiProduct = response.product,
               let name = apiProduct.product_name {
                let nutr = apiProduct.nutriments
                let food = FoodItem(
                    id: UUID(),
                    name: name,
                    calories: Int(nutr?.energy_kcal_100g ?? 0),
                    protein: nutr?.proteins_100g ?? 0,
                    carbs: nutr?.carbohydrates_100g ?? 0,
                    fat: nutr?.fat_100g ?? 0,
                    grams: 100,
                    mealType: "Scanned",
                    date: date,
                    isUserAdded: false,
                    barcode: barcode
                )
                self.currentProduct = food
                self.errorMessage = nil
            } else {
                self.currentProduct = nil
                self.errorMessage = "Product not found for barcode \(barcode)"
            }
        } catch {
            self.currentProduct = nil
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Mutations
    func logConsumption(of foodItem: FoodItem, grams: Double, mealType: String) {
        let foodEntity = fetchOrCreateFoodEntity(for: foodItem)
        let entry = ConsumptionEntity(context: context)
        entry.id = UUID()
        entry.food = foodEntity
        entry.dateEaten = Calendar.current.date(byAdding: .hour, value: 12, to: date)
        entry.gramsConsumed = grams
        entry.mealType = mealType
        do {
            try context.save()
            // Write this consumption into HealthKit
            let eatenDate = entry.dateEaten!
            let entryCalories = foodEntity.calories * (grams / 100.0)
            let entryProtein  = foodEntity.protein  * (grams / 100.0)
            let entryCarbs    = foodEntity.carbs    * (grams / 100.0)
            let entryFat      = foodEntity.fat      * (grams / 100.0)

            HealthKitManager.shared.saveNutritionSample(
                type: .dietaryEnergyConsumed,
                quantity: entryCalories,
                date: eatenDate
            ) { _, _ in }

            HealthKitManager.shared.saveNutritionSample(
                type: .dietaryProtein,
                quantity: entryProtein,
                date: eatenDate
            ) { _, _ in }

            HealthKitManager.shared.saveNutritionSample(
                type: .dietaryCarbohydrates,
                quantity: entryCarbs,
                date: eatenDate
            ) { _, _ in }

            HealthKitManager.shared.saveNutritionSample(
                type: .dietaryFatTotal,
                quantity: entryFat,
                date: eatenDate
            ) { _, _ in }
            loadEntries()
        } catch {
            print("Error saving consumption for date \(date):", error)
        }
    }

    func removeFood(by id: UUID) {
        let req: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entries = try context.fetch(req)
            for e in entries {
                // Remove this consumption from HealthKit
                if let eatenDate = e.dateEaten {
                    HealthKitManager.shared.deleteNutritionSamples(
                        type: .dietaryEnergyConsumed,
                        start: eatenDate,
                        end: eatenDate
                    ) { _, _ in }
                    HealthKitManager.shared.deleteNutritionSamples(
                        type: .dietaryProtein,
                        start: eatenDate,
                        end: eatenDate
                    ) { _, _ in }
                    HealthKitManager.shared.deleteNutritionSamples(
                        type: .dietaryCarbohydrates,
                        start: eatenDate,
                        end: eatenDate
                    ) { _, _ in }
                    HealthKitManager.shared.deleteNutritionSamples(
                        type: .dietaryFatTotal,
                        start: eatenDate,
                        end: eatenDate
                    ) { _, _ in }
                }
                context.delete(e)
            }
            try context.save()
            loadEntries()
        } catch {
            print("Error deleting entry \(id) on date \(date):", error)
        }
    }

    // MARK: - Private Helper
    private func fetchOrCreateFoodEntity(for foodItem: FoodItem) -> FoodEntity {
        let fetch: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %@", foodItem.id as CVarArg)
        if let existing = (try? context.fetch(fetch))?.first {
            return existing
        }
        let entity = FoodEntity(context: context)
        entity.id = foodItem.id
        entity.name = foodItem.name
        entity.calories = Double(foodItem.calories)
        entity.protein = foodItem.protein
        entity.carbs = foodItem.carbs
        entity.fat = foodItem.fat
        entity.grams = foodItem.grams
        entity.mealType = foodItem.mealType
        entity.date = Date.distantPast
        entity.isUserAdded = false
        entity.barcode = foodItem.barcode
        return entity
    }
}

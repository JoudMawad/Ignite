// FoodViewModel.swift

import Foundation
import CoreData

/// FoodViewModel manages a collection of FoodItem objects, including:
/// - adding/searching by barcode
/// - tracking today’s nutritional totals
/// - persisting food entries
/// - rolling calories into history at midnight
@MainActor
final class FoodViewModel: ObservableObject, FoodAddingViewModel {
    // MARK: - Published Properties

    @Published var foodItems: [FoodItem] = []

    /// Today’s total calories.
    @Published var totalCalories: Int = 0
    /// Today’s total protein.
    @Published var totalProtein: Double = 0
    /// Today’s total carbohydrates.
    @Published var totalCarbs: Double = 0
    /// Today’s total fat.
    @Published var totalFat: Double = 0

    /// The product fetched from the API
    @Published var currentProduct: FoodItem?
    /// Error message if fetching fails
    @Published var errorMessage: String?

    // MARK: - FoodAddingViewModel Conformance
    /// All available foods fetched from Core Data.
    var allFoods: [FoodItem] {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntity.name, ascending: true)]
        do {
            let entities = try context.fetch(request)
            return entities.map { e in
                FoodItem(
                    id: e.id ?? UUID(),
                    name: e.name ?? "",
                    calories: Int(e.calories),
                    protein: e.protein,
                    carbs: e.carbs,
                    fat: e.fat,
                    grams: e.grams,
                    mealType: e.mealType ?? "",
                    date: e.date ?? Date(),
                    isUserAdded: e.isUserAdded,
                    barcode: e.barcode
                )
            }
        } catch {
            print("Error fetching all foods: \(error)")
            return []
        }
    }

    /// Finds a food by barcode.
    func findFood(byBarcode code: String) -> FoodItem? {
        return findFoodByBarcode(code)
    }

    // MARK: - Internal Managers

    /// Handles history and midnight reset.
    private let calorieHistoryManager = CalorieHistoryManager()
    private let context: NSManagedObjectContext

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
        loadEntries()
    }

    /// Logs a consumption event for a given FoodItem and updates today’s history entry.
    func logConsumption(of foodItem: FoodItem, grams: Double, mealType: String) {
        // 1. Find or seed the catalog item
        let foodReq: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        foodReq.predicate = NSPredicate(format: "id == %@", foodItem.id as CVarArg)
        let foodEntity: FoodEntity
        if let existing = (try? context.fetch(foodReq))?.first {
            foodEntity = existing
        } else {
            foodEntity = FoodEntity(context: context)
            foodEntity.id = foodItem.id
            foodEntity.name = foodItem.name
            foodEntity.calories = Double(foodItem.calories)
            foodEntity.protein = foodItem.protein
            foodEntity.carbs = foodItem.carbs
            foodEntity.fat = foodItem.fat
            foodEntity.grams = foodItem.grams
            foodEntity.mealType = foodItem.mealType
            foodEntity.date = Date.distantPast
            foodEntity.isUserAdded = false
            foodEntity.barcode = foodItem.barcode
        }

        // 2. Create a ConsumptionEntity entry
        let entry = ConsumptionEntity(context: context)
        entry.id = UUID()
        entry.food = foodEntity
        entry.dateEaten = Date()
        entry.gramsConsumed = grams
        entry.mealType = mealType

        do {
            // 3. Save the consumption and reload diary entries
            try context.save()
            loadEntries()
            objectWillChange.send()

            // 4. Compute today’s total calories
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let consumptionReq: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
            consumptionReq.predicate = NSPredicate(format: "dateEaten >= %@ AND dateEaten < %@", startOfDay as NSDate, endOfDay as NSDate)
            let todaysEntries = try context.fetch(consumptionReq)
            let todaysCalories = todaysEntries.reduce(0) { sum, entry in
                guard let per100 = entry.food?.calories else { return sum }
                return sum + Int(per100 * (entry.gramsConsumed / 100.0))
            }

            // 5. Format today’s date string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())

            // 6. Fetch or create the CalorieEntry for today
            let historyReq: NSFetchRequest<CalorieEntry> = CalorieEntry.fetchRequest()
            historyReq.predicate = NSPredicate(format: "dateString == %@", dateString)
            let historyEntry = (try? context.fetch(historyReq))?.first ?? CalorieEntry(context: context)
            historyEntry.dateString = dateString
            historyEntry.calories = Int32(todaysCalories)

            // 7. Save the updated history
            try context.save()
        } catch {
            print("Error logging consumption or updating history: \(error)")
        }
    }

    // MARK: - Barcode Lookup

    // Catalog lookup remains unchanged; no edits needed.
    /// Searches both built-in and user-saved foods for a matching barcode.
    /// - Returns: the first FoodItem with .barcode == code, or nil.
    func findFoodByBarcode(_ code: String) -> FoodItem? {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "barcode == %@", code)
        if let e = (try? context.fetch(request))?.first {
            return FoodItem(
                id: e.id ?? UUID(),
                name: e.name ?? "",
                calories: Int(e.calories),
                protein: e.protein,
                carbs: e.carbs,
                fat: e.fat,
                grams: e.grams,
                mealType: e.mealType ?? "",
                date: e.date ?? Date(),
                isUserAdded: e.isUserAdded,
                barcode: e.barcode
            )
        }
        return nil
    }

    /// Fetch product data from Open Food Facts API for the given barcode
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
                    name: name,
                    calories: Int(nutr?.energy_kcal_100g ?? 0),
                    protein: nutr?.proteins_100g ?? 0,
                    carbs: nutr?.carbohydrates_100g ?? 0,
                    fat: nutr?.fat_100g ?? 0,
                    grams: 100,
                    mealType: "Scanned",
                    date: Date(),
                    isUserAdded: false,
                    barcode: barcode
                )
                self.currentProduct = food
                // Persist fetched product into your Core Data catalog (but don't log it as eaten yet)
                            do {
                                let req: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
                                req.predicate = NSPredicate(format: "barcode == %@", barcode)
                                let entity = (try context.fetch(req)).first ?? FoodEntity(context: context)
                                entity.id         = food.id
                                entity.name       = food.name
                                entity.calories   = Double(food.calories)
                                entity.protein    = food.protein
                                entity.carbs      = food.carbs
                                entity.fat        = food.fat
                                entity.grams      = food.grams
                                entity.mealType   = food.mealType
                                entity.date       = food.date
                                entity.isUserAdded = false
                                entity.barcode    = food.barcode
                                try context.save()
                            } catch {
                                print("Error saving scanned product: \(error)")
                            }
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

    // MARK: - Totals Calculation

    /// Recalculates today’s nutritional totals.
    private func updateTotals() {
        DispatchQueue.main.async {
            let today = Calendar.current.startOfDay(for: Date())
            let todayFoods = self.foodItems.filter {
                Calendar.current.isDate($0.date, inSameDayAs: today)
            }

            self.totalCalories = todayFoods.reduce(0) { $0 + $1.calories }
            self.totalProtein  = todayFoods.reduce(0) { $0 + $1.protein }
            self.totalCarbs    = todayFoods.reduce(0) { $0 + $1.carbs }
            self.totalFat      = todayFoods.reduce(0) { $0 + $1.fat }

            self.objectWillChange.send()
        }
    }

    /// Returns total calories for a specific meal type today.
    func totalCaloriesForMealType(_ mealType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return foodItems
            .filter { $0.mealType == mealType && Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories }
    }

    /// Fetches historical calories for a specific past date.
    func totalCaloriesForDate(_ date: Date) -> Int {
        calorieHistoryManager.totalCaloriesForDate(date)
    }
    
    /// Returns the total calories for each of the last `days` days.
    func totalCalories(forLast days: Int) -> [(date: String, calories: Int)] {
        calorieHistoryManager.totalCaloriesForPeriod(days: days)
    }
    
    /// Removes a food entry from today's diary by its UUID (consumption entry).
    func removeFood(by id: UUID) {
        let request: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entries = try context.fetch(request)
            for entry in entries {
                context.delete(entry)
            }
            try context.save()
            loadEntries()
            objectWillChange.send()
        } catch {
            print("Error deleting food diary entry: \(error)")
        }
    }

    /// Loads today’s consumption entries from Core Data.
    func loadEntries() {
        let request: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
        // Only today’s entries
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        request.predicate = NSPredicate(
            format: "dateEaten >= %@ AND dateEaten < %@",
            start as NSDate, end as NSDate
        )
        do {
            let entries = try context.fetch(request)
            self.foodItems = entries.compactMap { entry in
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
                    date: entry.dateEaten ?? Date(),
                    isUserAdded: true,
                    barcode: fe.barcode
                )
            }
            updateTotals()
        } catch {
            print("Error loading diary entries: \(error)")
        }
    }
}

// MARK: - Open Food Facts API Models
struct ProductResponse: Codable {
    let product: APIProduct?
}

struct APIProduct: Codable {
    let code: String?
    let product_name: String?
    let nutriments: Nutriments?
}

struct Nutriments: Codable {
    let energy_kcal_100g: Double?
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?

    enum CodingKeys: String, CodingKey {
        case energy_kcal_100g = "energy-kcal_100g"
        case proteins_100g = "proteins_100g"
        case carbohydrates_100g = "carbohydrates_100g"
        case fat_100g = "fat_100g"
    }
}

// MARK: - Open Food Facts Search API Models
struct SearchResponse: Codable {
    let products: [APIProduct]
}

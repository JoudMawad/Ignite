// FoodViewModel.swift

import Foundation

/// FoodViewModel manages a collection of FoodItem objects, including:
/// - adding/searching by barcode
/// - tracking today’s nutritional totals
/// - persisting food entries
/// - rolling calories into history at midnight
class FoodViewModel: ObservableObject {
    // MARK: - Published Properties

    /// All recorded food items; saved to UserDefaults on change.
    @Published var foodItems: [FoodItem] = [] {
        didSet { saveToUserDefaults() }
    }

    /// Today’s total calories.
    @Published var totalCalories: Int = 0
    /// Today’s total protein.
    @Published var totalProtein: Double = 0
    /// Today’s total carbohydrates.
    @Published var totalCarbs: Double = 0
    /// Today’s total fat.
    @Published var totalFat: Double = 0

    // MARK: - Internal Managers

    /// Handles history and midnight reset.
    private let calorieHistoryManager = CalorieHistoryManager()

    // MARK: - Initialization

    init() {
        loadFromUserDefaults()
        calorieHistoryManager.checkForMidnightReset(foodItems: foodItems)
    }

    // MARK: - Adding Food

    /// Adds a new user‐entered food item, optionally with a scanned barcode.
    func addFood(
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        grams: Double,
        mealType: String,
        barcode: String? = nil
    ) {
        let newFood = FoodItem(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            grams: grams,
            mealType: mealType,
            date: Date(),
            isUserAdded: true,
            barcode: barcode
        )
        foodItems.append(newFood)
        updateTotals()
    }

    /// Adds a predefined or user‐saved food, scaling nutrition to the grams consumed.
    /// Carries forward any existing barcode on the source FoodItem.
    func addPredefinedFood(
        food: FoodItem,
        gramsConsumed: Double,
        mealType: String
    ) {
        let adjustedCalories = Int((Double(food.calories) * gramsConsumed) / 100.0)
        let adjustedProtein  = (food.protein * gramsConsumed) / 100.0
        let adjustedCarbs    = (food.carbs * gramsConsumed) / 100.0
        let adjustedFat      = (food.fat * gramsConsumed) / 100.0

        let newFood = FoodItem(
            name: food.name,
            calories: adjustedCalories,
            protein: adjustedProtein,
            carbs: adjustedCarbs,
            fat: adjustedFat,
            grams: gramsConsumed,
            mealType: mealType,
            date: Calendar.current.startOfDay(for: Date()),
            isUserAdded: false,
            barcode: food.barcode
        )
        foodItems.append(newFood)
        updateTotals()
    }

    /// Persists a new custom “predefined” food so it appears in your Saved list.
    func addUserPredefinedFood(food: FoodItem) {
        PreDefinedUserFoods.shared.addFood(food)
    }

    // MARK: - Removing Food

    /// Removes a food entry by its UUID and updates totals.
    func removeFood(by id: UUID) {
        foodItems.removeAll { $0.id == id }
        updateTotals()
    }

    // MARK: - Barcode Lookup

    /// Searches both built-in and user-saved foods for a matching barcode.
    /// - Returns: the first FoodItem with .barcode == code, or nil.
    func findFoodByBarcode(_ code: String) -> FoodItem? {
        let allFoods = PredefinedFoods.foods + PreDefinedUserFoods.shared.foods
        return allFoods.first { $0.barcode == code }
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
            self.saveToUserDefaults()
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

    /// Fetches historical totals for a range (e.g., week, month).
    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        calorieHistoryManager.totalCaloriesForPeriod(days: days)
    }

    // MARK: - Persistence

    /// Saves the foodItems array to UserDefaults.
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }

    /// Loads saved foodItems from UserDefaults and updates totals.
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "foodItems"),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) {
            self.foodItems = decoded
            updateTotals()
        }
    }
}

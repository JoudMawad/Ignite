import Foundation

// FoodViewModel manages a collection of FoodItem objects and tracks nutritional totals for today.
// It also integrates with a calorie history manager to automatically save daily data.
class FoodViewModel: ObservableObject {
    // Published list of food items. Whenever foodItems changes, it is automatically saved to UserDefaults.
    @Published var foodItems: [FoodItem] = [] {
        didSet { saveToUserDefaults() }
    }
    
    // Published nutritional totals that the UI can observe.
    @Published var totalCalories: Int = 0
    @Published var totalProtein: Double = 0
    @Published var totalCarbs: Double = 0
    @Published var totalFat: Double = 0
    
    // An instance of CalorieHistoryManager to manage and check daily calorie history.
    private let calorieHistoryManager = CalorieHistoryManager() // Separate history tracking

    init() {
        // Load any saved food items from UserDefaults when the view model is created.
        loadFromUserDefaults()
        // Automatically check if it is time to save yesterday's data at midnight.
        calorieHistoryManager.checkForMidnightReset(foodItems: foodItems)
    }
    
    /// Adds a new food item provided by the user.
    func addFood(name: String, calories: Int, protein: Double, carbs: Double, fat: Double, grams: Double, mealType: String) {
        let newFood = FoodItem(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            grams: grams,
            mealType: mealType,
            date: Date(), // Uses the current date/time.
            isUserAdded: true
        )
        
        foodItems.append(newFood)
        updateTotals() // Update today's nutritional totals.
    }
    
    /// Adds a predefined food by adjusting its nutritional values based on grams consumed.
    func addPredefinedFood(food: FoodItem, gramsConsumed: Double, mealType: String) {
        // Adjust the nutritional values proportionally to grams consumed (assuming per 100g basis).
        let adjustedCalories = Int((Double(food.calories) * gramsConsumed) / 100.0)
        let adjustedProtein = (food.protein * gramsConsumed) / 100.0
        let adjustedCarbs = (food.carbs * gramsConsumed) / 100.0
        let adjustedFat = (food.fat * gramsConsumed) / 100.0
        
        let newFood = FoodItem(
            id: UUID(), // New ID for the consumed food.
            name: food.name,
            calories: adjustedCalories,
            protein: adjustedProtein,
            carbs: adjustedCarbs,
            fat: adjustedFat,
            grams: gramsConsumed,
            mealType: mealType,
            date: Calendar.current.startOfDay(for: Date()), // Recorded for today.
            isUserAdded: false
        )
        
        foodItems.append(newFood)
        updateTotals() // Recalculate totals.
    }
    
    /// Adds a user-defined predefined food to a shared list.
    func addUserPredefinedFood(food: FoodItem) {
        PredefinedUserFoods.shared.addFood(food)
    }

    /// Removes a food item from the list by its unique ID.
    func removeFood(by id: UUID) {
        foodItems.removeAll { $0.id == id }
        updateTotals() // Update totals after removal.
    }

    /// Updates the daily nutritional totals (calories, protein, carbs, fat) for today.
    private func updateTotals() {
        DispatchQueue.main.async {
            // Get today's date starting from midnight.
            let today = Calendar.current.startOfDay(for: Date())
            // Filter food items to include only those recorded today.
            let todayFoods = self.foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            
            // Calculate totals by summing up the respective properties.
            self.totalCalories = todayFoods.reduce(0) { $0 + $1.calories }
            self.totalProtein = todayFoods.reduce(0) { $0 + $1.protein }
            self.totalCarbs = todayFoods.reduce(0) { $0 + $1.carbs }
            self.totalFat = todayFoods.reduce(0) { $0 + $1.fat }
            
            // Notify observers that the totals have updated.
            self.objectWillChange.send()
            // Save updated data to persistent storage.
            self.saveToUserDefaults()
        }
    }
    
    /// Returns the total calories for a specified meal type (e.g., Breakfast, Lunch) for today.
    func totalCaloriesForMealType(_ mealType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return foodItems
            .filter { $0.mealType == mealType && Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories }
    }

    /// Fetches the total calories for a specific date from the calorie history manager.
    func totalCaloriesForDate(_ date: Date) -> Int {
        return calorieHistoryManager.totalCaloriesForDate(date)
    }

    /// Fetches calorie totals for a period (e.g., a week, month, year) from the calorie history manager.
    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        return calorieHistoryManager.totalCaloriesForPeriod(days: days)
    }
    
    // MARK: - Persistence Methods
    
    /// Saves the current food items list to UserDefaults.
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }
    
    /// Loads food items from UserDefaults and updates the totals.
    private func loadFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "foodItems"),
           let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
            self.foodItems = decodedFoods
            updateTotals()
        }
    }
}

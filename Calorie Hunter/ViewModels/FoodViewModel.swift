import Foundation

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet { saveToUserDefaults() }
    }
    
    @Published var totalCalories: Int = 0
    @Published var totalProtein: Double = 0
    @Published var totalCarbs: Double = 0
    @Published var totalFat: Double = 0
    
    private let calorieHistoryManager = CalorieHistoryManager() // Separate history tracking

    init() {
        loadFromUserDefaults()
        calorieHistoryManager.checkForMidnightReset(foodItems: foodItems) // Auto-save at 12 AM
    }
    
    func addFood(name: String, calories: Int, protein: Double, carbs: Double, fat: Double, grams: Double, mealType: String) {
        let newFood = FoodItem(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            grams: grams,
            mealType: mealType,
            date: Date(),
            isUserAdded: true
        )
        
        foodItems.append(newFood)
        updateTotals()
    }
    
    func addPredefinedFood(food: FoodItem, gramsConsumed: Double, mealType: String) {
        let adjustedCalories = Int((Double(food.calories) * gramsConsumed) / 100.0)
        let adjustedProtein = (food.protein * gramsConsumed) / 100.0
        let adjustedCarbs = (food.carbs * gramsConsumed) / 100.0
        let adjustedFat = (food.fat * gramsConsumed) / 100.0
        
        let newFood = FoodItem(
            id: UUID(),
            name: food.name,
            calories: adjustedCalories,
            protein: adjustedProtein,
            carbs: adjustedCarbs,
            fat: adjustedFat,
            grams: gramsConsumed,
            mealType: mealType,
            date: Calendar.current.startOfDay(for: Date()),
            isUserAdded: false
        )
        
        foodItems.append(newFood)
        updateTotals()
    }
    
    func addUserPredefinedFood(food: FoodItem) {
        PredefinedUserFoods.shared.addFood(food)
    }

    func removeFood(by id: UUID) {
        foodItems.removeAll { $0.id == id }
        updateTotals()
    }

    private func updateTotals() {
        DispatchQueue.main.async {
            let today = Calendar.current.startOfDay(for: Date())
            let todayFoods = self.foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            
            self.totalCalories = todayFoods.reduce(0) { $0 + $1.calories }
            self.totalProtein = todayFoods.reduce(0) { $0 + $1.protein }
            self.totalCarbs = todayFoods.reduce(0) { $0 + $1.carbs }
            self.totalFat = todayFoods.reduce(0) { $0 + $1.fat }
            
            self.objectWillChange.send()
            self.saveToUserDefaults()
        }
    }
    
    func totalCaloriesForMealType(_ mealType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return foodItems
            .filter { $0.mealType == mealType && Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories }
    }


    // Fetch total calories for a specific date
    func totalCaloriesForDate(_ date: Date) -> Int {
        return calorieHistoryManager.totalCaloriesForDate(date)
    }

    // Fetch calories for a specific period (week, month, year)
    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        return calorieHistoryManager.totalCaloriesForPeriod(days: days)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }
    
    private func loadFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "foodItems"),
           let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
            self.foodItems = decodedFoods
            updateTotals()
        }
    }
}

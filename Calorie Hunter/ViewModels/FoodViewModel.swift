import Foundation

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet { saveToUserDefaults() }
    }

    @Published var totalCalories: Int = 0
    @Published var totalProtein: Double = 0
    @Published var totalCarbs: Double = 0
    @Published var totalFat: Double = 0

    init() {
        loadFromUserDefaults()
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
            mealType: mealType, // ✅ Use the user-selected meal type
            date: Calendar.current.startOfDay(for: Date()), // ✅ Ensure correct date
            isUserAdded: false
        )

        foodItems.append(newFood)
        updateTotals()
    }
    
    func resetAll() {
        foodItems.removeAll() // Remove all food items
        totalCalories = 0
        totalProtein = 0
        totalCarbs = 0
        totalFat = 0
        saveToUserDefaults() // Optionally save the reset state
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

            self.objectWillChange.send() // ✅ Ensures UI refresh!
            self.saveToUserDefaults()
        }
    }


    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }

    func loadFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "foodItems"),
           let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
            self.foodItems = decodedFoods
            updateTotals()
        }
    }
}

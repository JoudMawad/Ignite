import Foundation

struct FoodItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let grams: Double
    let mealType: String
    let date: Date
    let isUserAdded: Bool

    init(id: UUID = UUID(), name: String, calories: Int, protein: Double, carbs: Double, fat: Double, grams: Double, mealType: String, date: Date = Date(), isUserAdded: Bool = false) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.grams = grams
        self.mealType = mealType
        self.date = date
        self.isUserAdded = isUserAdded
    }

    //Ensure FoodItem is Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id
    }
}

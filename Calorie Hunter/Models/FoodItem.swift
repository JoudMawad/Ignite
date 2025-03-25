import Foundation

// The FoodItem struct represents a food item in your app.
// It includes nutritional info, meal type, and the date the food was consumed.
// It also conforms to Identifiable, Codable, and Hashable to work seamlessly with SwiftUI, data storage, and collections.
struct FoodItem: Identifiable, Codable, Hashable {
    // A unique identifier for each food item.
    let id: UUID
    // The name of the food item.
    let name: String
    // Calories contained in the food item.
    let calories: Int
    // Amount of protein in grams.
    let protein: Double
    // Amount of carbohydrates in grams.
    let carbs: Double
    // Amount of fat in grams.
    let fat: Double
    // Weight of the food item in grams.
    let grams: Double
    // A string representing the meal type (e.g., Breakfast, Lunch, Dinner, or Snack).
    let mealType: String
    // The date and time when the food was recorded.
    let date: Date
    // A flag indicating if the food item was added manually by the user.
    let isUserAdded: Bool

    // Custom initializer with default values where applicable.
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

    // MARK: - Conformance to Hashable

    // This function ensures that FoodItem is hashable by hashing its unique identifier.
    // It allows FoodItem instances to be used in sets and as dictionary keys.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Equatable conformance: two FoodItems are considered equal if they have the same unique id.
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id
    }
}

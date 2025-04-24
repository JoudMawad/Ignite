// FoodItem.swift
import Foundation

/// The FoodItem struct represents a food item in your app.
/// It includes nutritional info, meal type, date consumed, and an optional barcode.
/// Conforms to Identifiable, Codable, and Hashable.
struct FoodItem: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// A unique identifier for each food item.
    let id: UUID
    /// The name of the food item.
    let name: String
    /// Calories contained in the food item.
    let calories: Int
    /// Amount of protein in grams.
    let protein: Double
    /// Amount of carbohydrates in grams.
    let carbs: Double
    /// Amount of fat in grams.
    let fat: Double
    /// Weight of the food item in grams.
    let grams: Double
    /// A string representing the meal type (e.g., Breakfast, Lunch, Dinner, Snack).
    let mealType: String
    /// The date and time when the food was recorded.
    let date: Date
    /// A flag indicating if the food item was added manually by the user.
    let isUserAdded: Bool
    /// The barcode associated with this food item (if any).
    let barcode: String?

    // MARK: - Initializer

    /// Custom initializer with default values for id, date, isUserAdded, and barcode.
    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        grams: Double,
        mealType: String,
        date: Date = Date(),
        isUserAdded: Bool = false,
        barcode: String? = nil
    ) {
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
        self.barcode = barcode
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Equatable

    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id
    }
}

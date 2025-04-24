// PreDefinedUserFoods.swift
import Foundation

/// This class manages a list of user-defined (predefined) foods,
/// persisting them in UserDefaults.
class PreDefinedUserFoods {
    // Singleton instance for global access.
    static let shared = PreDefinedUserFoods()

    // UserDefaults key.
    private let userPredefinedFoodKey = "userPredefinedFoods"

    /// Computed property to get/set the array of FoodItem.
    var foods: [FoodItem] {
        get {
            if let savedData = UserDefaults.standard.data(forKey: userPredefinedFoodKey),
               let decoded = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
                return decoded
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: userPredefinedFoodKey)
            }
        }
    }

    /// Add a new FoodItem to the list.
    func addFood(_ food: FoodItem) {
        var current = foods
        current.append(food)
        foods = current
    }

    /// Remove a FoodItem by its UUID.
    func removeFood(by id: UUID) {
        var current = foods
        current.removeAll { $0.id == id }
        foods = current
    }
}

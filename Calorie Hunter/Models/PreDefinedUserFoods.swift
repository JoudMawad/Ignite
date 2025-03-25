//
//  PreDefinedUserFoods.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import Foundation

// This class manages a list of predefined foods for the user.
// It allows you to retrieve, add, or remove foods that the user has pre-selected.
class PredefinedUserFoods {
    // Singleton instance so you can easily access these foods anywhere in the app.
    static let shared = PredefinedUserFoods()
    
    // The key used to store and retrieve the predefined foods from UserDefaults.
    private let userPredefinedFoodKey = "userPredefinedFoods"
    
    // This computed property handles getting and setting the list of predefined foods.
    var foods: [FoodItem] {
        get {
            // Try to load the saved data from UserDefaults.
            if let savedData = UserDefaults.standard.data(forKey: userPredefinedFoodKey),
               let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
                // If decoding is successful, return the saved foods.
                return decodedFoods
            }
            // If there's no data, return an empty array.
            return []
        }
        set {
            // Try to encode the new array of foods into data.
            if let encoded = try? JSONEncoder().encode(newValue) {
                // Save the encoded data to UserDefaults.
                UserDefaults.standard.set(encoded, forKey: userPredefinedFoodKey)
            }
        }
    }
    
    // Adds a new food item to the predefined list.
    func addFood(_ food: FoodItem) {
        // Get the current list of foods.
        var currentFoods = foods
        // Append the new food item.
        currentFoods.append(food)
        // Save the updated list back to UserDefaults.
        foods = currentFoods
    }
    
    // Removes a food item from the predefined list by its unique identifier.
    func removeFood(by id: UUID) {
        // Get the current list of foods.
        var currentFoods = foods
        // Remove any food item that matches the provided id.
        currentFoods.removeAll { $0.id == id }
        // Save the updated list back to UserDefaults.
        foods = currentFoods
    }
}

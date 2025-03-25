//
//  PreDefinedUserFoodsViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import Foundation

// UserPreDefinedFoodsViewModel is responsible for managing the list of predefined foods
// that the user has saved. It retrieves and updates the list from a shared data store.
class UserPreDefinedFoodsViewModel: ObservableObject {
    // Published property that holds the list of predefined food items.
    // When this array changes, the UI will automatically update.
    @Published var foods: [FoodItem] = []
    
    // Initializer loads the saved predefined foods when an instance is created.
    init() {
        loadFoods()
    }
    
    /// Loads the predefined foods from the shared data store.
    func loadFoods() {
        foods = PredefinedUserFoods.shared.foods
    }
    
    /// Removes a food item from the shared data store using its unique identifier.
    /// - Parameter id: The unique identifier of the food item to remove.
    func removeFood(by id: UUID) {
        PredefinedUserFoods.shared.removeFood(by: id)
        loadFoods() // Refresh the list after deletion.
    }
    
    /// Deletes one or more food items at the specified indices.
    /// - Parameter offsets: The set of indices corresponding to the food items to delete.
    func deleteFood(at offsets: IndexSet) {
        for index in offsets {
            let foodId = foods[index].id
            removeFood(by: foodId)
        }
    }
}

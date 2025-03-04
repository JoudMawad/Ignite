//
//  PreDefinedUserFoodsViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import Foundation

class UserPreDefinedFoodsViewModel: ObservableObject {
    @Published var foods: [FoodItem] = []
    
    init() {
        loadFoods()
    }
    
    func loadFoods() {
        foods = PredefinedUserFoods.shared.foods
    }
    
    func removeFood(by id: UUID) {
        PredefinedUserFoods.shared.removeFood(by: id)
        loadFoods() // Refresh list after deletion
    }
    
    func deleteFood(at offsets: IndexSet) {
        for index in offsets {
            let foodId = foods[index].id
            removeFood(by: foodId)
        }
    }
}


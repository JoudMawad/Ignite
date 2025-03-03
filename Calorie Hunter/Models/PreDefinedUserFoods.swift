//
//  PreDefinedUserFoods.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import Foundation

class PredefinedUserFoods {
    static let shared = PredefinedUserFoods()
    
    private let userPredefinedFoodKey = "userPredefinedFoods"
    
    var foods: [FoodItem] {
        get {
            if let savedData = UserDefaults.standard.data(forKey: userPredefinedFoodKey),
               let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
                return decodedFoods
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: userPredefinedFoodKey)
            }
        }
    }
    
    func addFood(_ food: FoodItem) {
        var currentFoods = foods
        currentFoods.append(food)
        foods = currentFoods
    }
    
    func removeFood(by id: UUID) {
        var currentFoods = foods
        currentFoods.removeAll { $0.id == id }
        foods = currentFoods
    }
}

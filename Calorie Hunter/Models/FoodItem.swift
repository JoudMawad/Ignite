//
//  FoodItem.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 01.03.25.
//

import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID  // No default value
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let grams: Double
    let mealType: String

    // Custom initializer to provide a default UUID when creating new instances
    init(id: UUID = UUID(), name: String, calories: Int, protein: Double, carbs: Double, fat: Double, grams: Double, mealType: String) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.grams = grams
        self.mealType = mealType
    }
}


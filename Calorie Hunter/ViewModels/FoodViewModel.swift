//
//  FoodViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 01.03.25.
//

import Foundation

class FoodViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = [] {
        didSet {
            saveToUserDefaults()
        }
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
            id: UUID(),
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            grams: grams,
            mealType: mealType
        )

        foodItems.append(newFood)
        totalCalories += calories
        totalProtein += protein
        totalCarbs += carbs
        totalFat += fat

        saveToUserDefaults() // Ensure new totals are saved
    }

    func removeFood(at index: Int) {
        let removedFood = foodItems[index]

        // Update total values
        totalCalories -= removedFood.calories
        totalProtein -= removedFood.protein
        totalCarbs -= removedFood.carbs
        totalFat -= removedFood.fat

        // Remove from list
        foodItems.remove(at: index)

        saveToUserDefaults()
    }
    
    func resetFood() {
        foodItems.removeAll()
        totalCalories = 0
        totalProtein = 0
        totalCarbs = 0
        totalFat = 0
        saveToUserDefaults()
    }

    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
        UserDefaults.standard.set(totalCalories, forKey: "totalCalories")
        UserDefaults.standard.set(totalProtein, forKey: "totalProtein")
        UserDefaults.standard.set(totalCarbs, forKey: "totalCarbs")
        UserDefaults.standard.set(totalFat, forKey: "totalFat")
    }

    func loadFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "foodItems"),
           let decodedFoods = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
            self.foodItems = decodedFoods

            self.totalCalories = decodedFoods.reduce(0) { $0 + $1.calories }
            self.totalProtein = decodedFoods.reduce(0) { $0 + $1.protein }
            self.totalCarbs = decodedFoods.reduce(0) { $0 + $1.carbs }
            self.totalFat = decodedFoods.reduce(0) { $0 + $1.fat }
        } else {
            
            self.totalCalories = 0
            self.totalProtein = 0
            self.totalCarbs = 0
            self.totalFat = 0
        }
    }
}

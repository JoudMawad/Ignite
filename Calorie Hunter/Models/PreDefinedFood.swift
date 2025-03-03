//  PreDefinedFood.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import Foundation

struct PredefinedFoods {
    static let foods: [FoodItem] = [
        // Fruits
        FoodItem(name: "Apple", calories: 52, protein: 0.3, carbs: 14, fat: 0.2, grams: 100, mealType: "Snack"),
        FoodItem(name: "Banana", calories: 89, protein: 1.1, carbs: 23, fat: 0.3, grams: 100, mealType: "Snack"),
        FoodItem(name: "Orange", calories: 47, protein: 0.9, carbs: 12, fat: 0.1, grams: 100, mealType: "Snack"),
        FoodItem(name: "Strawberry", calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, grams: 100, mealType: "Snack"),
        FoodItem(name: "Grapes", calories: 69, protein: 0.7, carbs: 18, fat: 0.2, grams: 100, mealType: "Snack"),
        FoodItem(name: "Blueberry", calories: 57, protein: 0.7, carbs: 14, fat: 0.3, grams: 100, mealType: "Snack"),
        FoodItem(name: "Mango", calories: 60, protein: 0.8, carbs: 15, fat: 0.4, grams: 100, mealType: "Snack"),
        FoodItem(name: "Avocado", calories: 160, protein: 2, carbs: 9, fat: 15, grams: 100, mealType: "Lunch"),

        // Vegetables
        FoodItem(name: "Carrot", calories: 41, protein: 0.9, carbs: 10, fat: 0.2, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Broccoli", calories: 55, protein: 3.7, carbs: 11, fat: 0.6, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Spinach", calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Tomato", calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Cucumber", calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Potato", calories: 77, protein: 2, carbs: 17, fat: 0.1, grams: 100, mealType: "Lunch"),

        // Dairy
        FoodItem(name: "Milk", calories: 42, protein: 3.4, carbs: 5, fat: 1, grams: 100, mealType: "Breakfast"),
        FoodItem(name: "Cheese", calories: 402, protein: 25, carbs: 1.3, fat: 33, grams: 100, mealType: "Snack"),
        FoodItem(name: "Yogurt", calories: 59, protein: 3.5, carbs: 4.7, fat: 3.3, grams: 100, mealType: "Breakfast"),

        // Protein sources
        FoodItem(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Egg", calories: 155, protein: 13, carbs: 1.1, fat: 11, grams: 100, mealType: "Breakfast"),
        FoodItem(name: "Salmon", calories: 208, protein: 20, carbs: 0, fat: 13, grams: 100, mealType: "Dinner"),
        FoodItem(name: "Steak", calories: 271, protein: 25, carbs: 0, fat: 19, grams: 100, mealType: "Dinner"),
        FoodItem(name: "Tofu", calories: 76, protein: 8, carbs: 1.9, fat: 4.8, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Peanut Butter", calories: 588, protein: 25, carbs: 20, fat: 50, grams: 100, mealType: "Snack"),
        FoodItem(name: "Lentils", calories: 116, protein: 9, carbs: 20, fat: 0.4, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Chickpeas", calories: 164, protein: 8.9, carbs: 27, fat: 2.6, grams: 100, mealType: "Lunch"),

        // Grains & Starches
        FoodItem(name: "Rice", calories: 130, protein: 2.7, carbs: 28, fat: 0.3, grams: 100, mealType: "Dinner"),
        FoodItem(name: "Bread", calories: 265, protein: 9, carbs: 49, fat: 3.2, grams: 100, mealType: "Breakfast"),
        FoodItem(name: "Pasta", calories: 131, protein: 5, carbs: 25, fat: 1.2, grams: 100, mealType: "Dinner"),
        FoodItem(name: "Oats", calories: 389, protein: 16.9, carbs: 66.3, fat: 6.9, grams: 100, mealType: "Breakfast"),
        FoodItem(name: "Quinoa", calories: 120, protein: 4.1, carbs: 21.3, fat: 1.9, grams: 100, mealType: "Lunch"),
        FoodItem(name: "Corn", calories: 86, protein: 3.2, carbs: 19, fat: 1.2, grams: 100, mealType: "Lunch"),

        // Snacks & Beverages
        FoodItem(name: "Almonds", calories: 579, protein: 21, carbs: 22, fat: 49, grams: 100, mealType: "Snack"),
        FoodItem(name: "Walnuts", calories: 654, protein: 15, carbs: 14, fat: 65, grams: 100, mealType: "Snack"),
        FoodItem(name: "Dark Chocolate", calories: 546, protein: 4.9, carbs: 61, fat: 31, grams: 100, mealType: "Snack"),
        FoodItem(name: "Coffee", calories: 2, protein: 0.3, carbs: 0, fat: 0, grams: 100, mealType: "Snack"),
        FoodItem(name: "Green Tea", calories: 1, protein: 0, carbs: 0.2, fat: 0, grams: 100, mealType: "Snack"),

        // Fast Food & Treats
        FoodItem(name: "Pizza", calories: 266, protein: 11, carbs: 33, fat: 10, grams: 100, mealType: "Dinner"),
        FoodItem(name: "Burger", calories: 295, protein: 17, carbs: 30, fat: 12, grams: 100, mealType: "Dinner"),
        FoodItem(name: "French Fries", calories: 312, protein: 3.4, carbs: 41, fat: 15, grams: 100, mealType: "Snack"),
        FoodItem(name: "Ice Cream", calories: 207, protein: 3.5, carbs: 24, fat: 11, grams: 100, mealType: "Snack")
    ]
}

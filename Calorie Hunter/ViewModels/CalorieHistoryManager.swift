//
//  CalorieHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import Foundation

class CalorieHistoryManager {
    private let lastSavedDateKey = "lastSavedDate"
    private let dailyCaloriesKey = "dailyCaloriesHistory"

    /// **Checks at app launch if we need to save yesterday's calories (runs at midnight)**
    func checkForMidnightReset(foodItems: [FoodItem]) {
        let lastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: Date())

        if lastSavedDate < today {
            saveDailyCalories(foodItems: foodItems)
            UserDefaults.standard.set(today, forKey: lastSavedDateKey)
        }
    }

    /// **Saves yesterday's calorie total**
    private func saveDailyCalories(foodItems: [FoodItem]) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayFoods = foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: yesterday) }
        let yesterdayCalories = yesterdayFoods.reduce(0) { $0 + $1.calories }

        var history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        let dateString = formatDate(yesterday)
        history[dateString] = yesterdayCalories

        UserDefaults.standard.set(history, forKey: dailyCaloriesKey)
        print("Saved \(yesterdayCalories) kcal for \(dateString)")
    }

    /// **Fetch total calories for a specific date**
    func totalCaloriesForDate(_ date: Date) -> Int {
        let history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        let dateString = formatDate(date)
        return history[dateString] ?? 0
    }

    /// **Retrieve calorie data for a given time range (week, month, year)**
    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        let history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        var result: [(String, Int)] = []

        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                let kcal = history[dateString] ?? 0
                result.append((dateString, kcal))
            }
        }
        return result.reversed()
    }

    /// **Formats date to "YYYY-MM-DD"**
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

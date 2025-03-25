//
//  CalorieHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import Foundation

// This class helps manage your calorie history.
// It takes care of saving, resetting, and retrieving daily calorie data.
class CalorieHistoryManager {
    // Keys for storing our data in UserDefaults.
    private let lastSavedDateKey = "lastSavedDate"
    private let dailyCaloriesKey = "dailyCaloriesHistory"

    /// Checks at app launch if it's time to save yesterday's calorie data.
    /// This essentially runs around midnight to archive yesterday's total.
    func checkForMidnightReset(foodItems: [FoodItem]) {
        // Get the last date when calories were saved; if not found, assume a long time ago.
        let lastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date ?? Date.distantPast
        // Today is defined as the start of the current day.
        let today = Calendar.current.startOfDay(for: Date())

        // If the last saved date is before today, it's time to save yesterday's data.
        if lastSavedDate < today {
            saveDailyCalories(foodItems: foodItems)
            // Update the last saved date to today.
            UserDefaults.standard.set(today, forKey: lastSavedDateKey)
        }
    }

    /// Saves yesterday's total calorie count.
    /// It looks at all food items, filters out the ones from yesterday,
    /// calculates the total, and then saves it.
    private func saveDailyCalories(foodItems: [FoodItem]) {
        // Determine yesterday's date.
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        // Filter the food items to only those consumed yesterday.
        let yesterdayFoods = foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: yesterday) }
        // Sum up the calories from yesterday's food items.
        let yesterdayCalories = yesterdayFoods.reduce(0) { $0 + $1.calories }

        // Retrieve the current history from UserDefaults or start with an empty dictionary.
        var history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        // Format yesterday's date to a string so it can be used as a key.
        let dateString = formatDate(yesterday)
        // Update the history with yesterday's total calories.
        history[dateString] = yesterdayCalories

        // Save the updated history back into UserDefaults.
        UserDefaults.standard.set(history, forKey: dailyCaloriesKey)
        // Print a message to the console for debugging purposes.
        print("Saved \(yesterdayCalories) kcal for \(dateString)")
    }

    /// Fetches the total calories recorded for a specific date.
    /// - Parameter date: The date for which you want to see the calorie total.
    /// - Returns: The number of calories saved for that day, or 0 if none were saved.
    func totalCaloriesForDate(_ date: Date) -> Int {
        let history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        let dateString = formatDate(date)
        return history[dateString] ?? 0
    }

    /// Retrieves calorie data for a period (like a week, month, or year).
    /// It returns an array of tuples where each tuple contains a date string and the calories for that day.
    /// - Parameter days: The number of past days to include.
    /// - Returns: A chronologically ordered list (oldest first) of date and calorie pairs.
    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        let history = UserDefaults.standard.dictionary(forKey: dailyCaloriesKey) as? [String: Int] ?? [:]
        var result: [(String, Int)] = []

        // Loop for each day in the given period.
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                // Get the calories for the date, defaulting to 0 if no record exists.
                let kcal = history[dateString] ?? 0
                result.append((dateString, kcal))
            }
        }
        // Return the results so that the oldest date comes first.
        return result.reversed()
    }

    /// Formats a given date into a string formatted as "yyyy-MM-dd".
    /// This makes it easy to use dates as keys in our dictionary.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

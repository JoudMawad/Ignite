//
//  BurnedCaloriesHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import Foundation
import Combine

// This manager keeps track of burned calories history and makes it easy to access and update.
// It's a singleton, so you can get the shared instance anywhere in your app.
class BurnedCaloriesHistoryManager: ObservableObject {
    // Shared instance for the entire app.
    static let shared = BurnedCaloriesHistoryManager()
    
    // A unique key for storing our burned calories history in UserDefaults.
    private let dailyBurnedCaloriesKey = "dailyBurnedCaloriesHistory"
    
    // This computed property fetches the stored history from UserDefaults.
    // The history is a dictionary where the key is a date string (like "2025-03-25") and the value is the calories burned.
    private var localHistory: [String: Double] {
        get {
            // Try to get the stored dictionary; if it doesn't exist, just return an empty dictionary.
            UserDefaults.standard.dictionary(forKey: dailyBurnedCaloriesKey) as? [String: Double] ?? [:]
        }
        set {
            // Save the updated history to UserDefaults.
            UserDefaults.standard.set(newValue, forKey: dailyBurnedCaloriesKey)
            // Let any listening views know that something changed so they can update.
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    // MARK: - Importing Data
    
    /// Adds historical burned calories data to our stored history.
    /// - Parameter caloriesData: An array of tuples. Each tuple has a date string and the calories burned on that day.
    func importHistoricalBurnedCalories(_ caloriesData: [(date: String, burnedCalories: Double)]) {
        // Start with whatever history we already have.
        var history = localHistory
        // Loop through each entry in the new data and update our history.
        for entry in caloriesData {
            history[entry.date] = entry.burnedCalories
        }
        // Save the new history back to UserDefaults.
        localHistory = history
    }
    
    // MARK: - Retrieving Data
    
    /// Returns the burned calories for the last given number of days.
    /// - Parameter days: How many past days you want data for.
    /// - Returns: An array of tuples with the date and calories burned, ordered from the oldest date to the most recent.
    func burnedCaloriesForPeriod(days: Int) -> [(date: String, burnedCalories: Double)] {
        var results: [(String, Double)] = []
        // Set up a formatter to turn dates into strings like "yyyy-MM-dd".
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        // For each day in the period...
        for i in 0..<days {
            // Figure out the date 'i' days ago.
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                // Get the burned calories for this date, or use 0 if there's no record.
                let value = localHistory[dateString] ?? 0
                results.append((dateString, value))
            }
        }
        // Reverse the list so that the oldest date comes first.
        return results.reversed()
    }
    
    // MARK: - Data Management
    
    /// Clears all the stored burned calories data.
    func clearData() {
        localHistory = [:]
    }
}

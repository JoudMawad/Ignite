//
//  BurnedCaloriesHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import Foundation
import Combine

class BurnedCaloriesHistoryManager: ObservableObject {
    static let shared = BurnedCaloriesHistoryManager()
    
    private let dailyBurnedCaloriesKey = "dailyBurnedCaloriesHistory"
    
    /// Local storage of burned calories keyed by date string ("yyyy-MM-dd")
    private var localHistory: [String: Double] {
        get {
            UserDefaults.standard.dictionary(forKey: dailyBurnedCaloriesKey) as? [String: Double] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyBurnedCaloriesKey)
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    
    /// Imports historical burned calories data.
    func importHistoricalBurnedCalories(_ caloriesData: [(date: String, burnedCalories: Double)]) {
        var history = localHistory
        for entry in caloriesData {
            history[entry.date] = entry.burnedCalories
        }
        localHistory = history
    }
    
    /// Returns burned calories for the last `days` days.
    func burnedCaloriesForPeriod(days: Int) -> [(date: String, burnedCalories: Double)] {
        var results: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                let value = localHistory[dateString] ?? 0
                results.append((dateString, value))
            }
        }
        return results.reversed()
    }
    
    /// Optional: Clears stored burned calories data.
    func clearData() {
        localHistory = [:]
    }
}

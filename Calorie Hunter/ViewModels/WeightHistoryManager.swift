//
//  WeightHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

//
//  WeightHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import Foundation

class WeightHistoryManager {
    private let lastSavedDateKey = "lastWeightSavedDate"
    private let dailyWeightKey = "dailyWeightHistory"

    /// **Checks if we need to save yesterday's weight at midnight**
    func checkForMidnightReset(currentWeight: Double) {
        let lastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: Date())

        if lastSavedDate < today {
            saveDailyWeight(currentWeight: currentWeight)
            UserDefaults.standard.set(today, forKey: lastSavedDateKey)
        }
    }

    public func saveDailyWeight(currentWeight: Double) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateString = formatDate(yesterday)

        var history = UserDefaults.standard.dictionary(forKey: dailyWeightKey) as? [String: Double] ?? [:]
        history[dateString] = currentWeight

        UserDefaults.standard.set(history, forKey: dailyWeightKey)
        print("Saved weight: \(currentWeight) kg for \(dateString)")
    }

    func weightForDate(_ date: Date) -> Double? {
        let history = UserDefaults.standard.dictionary(forKey: dailyWeightKey) as? [String: Double] ?? [:]
        let dateString = formatDate(date)
        return history[dateString]
    }

    func weightForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let history = UserDefaults.standard.dictionary(forKey: dailyWeightKey) as? [String: Double] ?? [:]
        var result: [(String, Double)] = []

        var lastKnownWeight: Double? = nil

        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                let weight = history[dateString] ?? lastKnownWeight ?? 70.0

                lastKnownWeight = weight
                result.append((dateString, weight))
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

//
//  ChartDataHelper.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import Foundation

struct ChartDataHelper {
    static func groupData(from calorieData: [(date: String, calories: Int)], days: Int, interval: Int, dateFormat: String) -> [(String, Int)] {
        stride(from: 0, to: days, by: interval).compactMap { offset -> (String, Int)? in
            let subrange = calorieData.suffix(days).dropFirst(offset).prefix(interval)
            guard !subrange.isEmpty else { return nil }
            let totalCalories = subrange.reduce(0) { $0 + $1.calories }
            let avgCalories = totalCalories / subrange.count
            let firstDate = stringToDate(subrange.first!.date)
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            return (formatter.string(from: firstDate), avgCalories)
        }
    }
    
    
    static func groupWeightData(from weightData: [(date: String, weight: Double)], days: Int, interval: Int, dateFormat: String) -> [(String, Double)] {
        let calendar = Calendar.current
        // Determine the start date (days ago from today)
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        var lastKnownWeight: Double? = nil
        var groupedData: [(String, Double)] = []

        // Iterate through the period in fixed intervals
        for offset in stride(from: 0, to: days, by: interval) {
            guard let intervalStartDate = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            let label = formatter.string(from: intervalStartDate)
            
            // Get the subrange for this interval
            let subrange = weightData.suffix(days).dropFirst(offset).prefix(interval)
            let weight: Double
            if subrange.isEmpty {
                // Use the last known weight if available; otherwise default to 0.0
                weight = lastKnownWeight ?? 0.0
            } else {
                let totalWeight = subrange.reduce(0) { $0 + $1.weight }
                weight = totalWeight / Double(subrange.count)
                lastKnownWeight = weight
            }
            groupedData.append((label, weight))
        }
        
        return groupedData
    }


    
    static func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    
    static func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}


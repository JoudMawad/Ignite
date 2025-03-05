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
    
    static func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}


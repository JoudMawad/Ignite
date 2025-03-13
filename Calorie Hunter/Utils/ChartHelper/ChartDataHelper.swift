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
    
    static func groupWeightData(from weightData: [(date: String, weight: Double)],
                                days: Int,
                                interval: Int,
                                dateFormat: String) -> [(String, Double)] {
        let calendar = Calendar.current
        
        // 1) Determine the overall start date (days - 1) days ago at midnight.
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) else {
            return []
        }
        // We'll call each interval "bucket" from [intervalStart, intervalEnd)
        // where intervalEnd = intervalStart + (interval days).
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        // 2) Convert each raw entry's date (string) to a Date.
        //    We'll store them as (Date, weight) for easier date comparisons.
        let processedData: [(Date, Double)] = weightData.map { entry in
            (calendar.startOfDay(for: stringToDate(entry.date)), entry.weight)
        }
        
        // 3) Sort the processed data by date (ascending).
        let sortedData = processedData.sorted { $0.0 < $1.0 }

        var lastKnownWeight: Double? = nil
        var groupedData: [(String, Double)] = []
        
        // 4) Generate each interval by offset in [0, days) in steps of `interval`.
        for offset in stride(from: 0, to: days, by: interval) {
            // The start of the interval
            guard let intervalStart = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            // The end of the interval (non-inclusive)
            guard let intervalEnd = calendar.date(byAdding: .day, value: interval, to: intervalStart) else { continue }
            
            // 5) Filter the sortedData to only those entries that fall within [intervalStart, intervalEnd).
            let subrange = sortedData.filter { (entryDate, _) in
                entryDate >= intervalStart && entryDate < intervalEnd
            }
            
            // 6) Calculate the average. If subrange is empty => fallback to lastKnownWeight or 0.
            let avgWeight: Double
            if subrange.isEmpty {
                avgWeight = lastKnownWeight ?? 0.0
            } else {
                let total = subrange.reduce(0.0) { $0 + $1.1 }
                avgWeight = total / Double(subrange.count)
                lastKnownWeight = avgWeight
            }
            
            // 7) The label is based on the start date of this interval.
            let label = dateFormatter.string(from: intervalStart)
            groupedData.append((label, avgWeight))
        }
        
        return groupedData
    }
    
    static func groupStepsData(from stepsData: [(date: String, steps: Int)],
                               days: Int,
                               interval: Int,
                               dateFormat: String) -> [(String, Int)]
    {
        // Reuse groupData under the hood by converting `steps` to `calories`.
        let mapped = stepsData.map { (date: $0.date, calories: $0.steps) }
        let grouped = groupData(from: mapped,
                                days: days,
                                interval: interval,
                                dateFormat: dateFormat)
        return grouped
    }
    
    // New: Group burned calories data.
    static func groupBurnedCaloriesData(from burnedCaloriesData: [(date: String, burnedCalories: Double)],
                                          days: Int,
                                          interval: Int,
                                          dateFormat: String) -> [(String, Double)]
    {
        return stride(from: 0, to: days, by: interval).compactMap { offset -> (String, Double)? in
            let subrange = burnedCaloriesData.suffix(days).dropFirst(offset).prefix(interval)
            guard !subrange.isEmpty else { return nil }
            let totalBurnedCalories = subrange.reduce(0.0) { $0 + $1.burnedCalories }
            let avgBurnedCalories = totalBurnedCalories / Double(subrange.count)
            let firstDate = stringToDate(subrange.first!.date)
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            return (formatter.string(from: firstDate), avgBurnedCalories)
        }
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

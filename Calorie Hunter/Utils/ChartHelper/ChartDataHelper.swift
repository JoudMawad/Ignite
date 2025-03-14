import Foundation

struct ChartDataHelper {
    
    /// Generic grouping function.
    ///
    /// - Parameters:
    ///   - rawData: An array of tuples with a date (as String) and a numeric value (as Double).
    ///   - days: Total number of days to consider (e.g. 30 for a month).
    ///   - interval: Size of each bucket in days.
    ///   - inputDateFormat: Format of the input date strings (default is "yyyy-MM-dd").
    ///   - outputDateFormat: Format for the bucket label.
    /// - Returns: An array of tuples (label, aggregatedValue) where aggregatedValue is the average value of that bucket.
    static func groupData(from rawData: [(date: String, value: Double)],
                          days: Int,
                          interval: Int,
                          inputDateFormat: String = "yyyy-MM-dd",
                          outputDateFormat: String) -> [(label: String, aggregatedValue: Double)] {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone.current
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputDateFormat
        outputFormatter.locale = Locale.current
        outputFormatter.timeZone = TimeZone.current
        
        // Parse raw data into sorted (Date, value) pairs.
        let dataPoints: [(date: Date, value: Double)] = rawData.compactMap { entry in
            if let date = inputFormatter.date(from: entry.date) {
                return (date: Calendar.current.startOfDay(for: date), value: entry.value)
            }
            return nil
        }.sorted { $0.date < $1.date }
        
        let calendar = Calendar.current
        // Calculate startDate as (days - 1) days ago from today.
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) else {
            return []
        }
        
        var groupedData: [(label: String, aggregatedValue: Double)] = []
        var lastKnownNonZero: Double? = nil
        
        // Process each bucket.
        for offset in stride(from: 0, to: days, by: interval) {
            guard let bucketStart = calendar.date(byAdding: .day, value: offset, to: startDate),
                  let bucketEnd = calendar.date(byAdding: .day, value: interval, to: bucketStart) else { continue }
            
            // Filter out any entries that are exactly 0.
            let bucketValues = dataPoints.filter { $0.date >= bucketStart && $0.date < bucketEnd && $0.value != 0.0 }
                                         .map { $0.value }
            
            let aggregatedValue: Double
            if bucketValues.isEmpty {
                // First, check if we have a last known nonzero value.
                if let last = lastKnownNonZero {
                    aggregatedValue = last
                } else {
                    // Search backward: iterate from bucketStart down to the earliest date.
                    var searchDate = bucketStart
                    var foundValue: Double? = nil
                    let earliestDate = dataPoints.first?.date ?? bucketStart
                    while searchDate > earliestDate {
                        if let nonZeroPoint = dataPoints.last(where: { $0.date < searchDate && $0.value != 0.0 }) {
                            foundValue = nonZeroPoint.value
                            break
                        }
                        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: searchDate) else {
                            break
                        }
                        searchDate = previousDate
                    }
                    if let found = foundValue {
                        aggregatedValue = found
                        lastKnownNonZero = found
                    } else {
                        // If nothing found going backward, search forward from bucketStart.
                        if let futureNonZeroPoint = dataPoints.first(where: { $0.date >= bucketStart && $0.value != 0.0 }) {
                            aggregatedValue = futureNonZeroPoint.value
                            lastKnownNonZero = futureNonZeroPoint.value
                        } else {
                            aggregatedValue = 0.0
                        }
                    }
                }
            } else {
                aggregatedValue = bucketValues.reduce(0.0, +) / Double(bucketValues.count)
                lastKnownNonZero = aggregatedValue
            }
            
            let label = outputFormatter.string(from: bucketStart)
            groupedData.append((label: label, aggregatedValue: aggregatedValue))
        }
        
        return groupedData
    }





    
    static func groupWeightData(from weightData: [(date: String, weight: Double)],
                                days: Int,
                                interval: Int,
                                inputDateFormat: String = "yyyy-MM-dd",
                                outputDateFormat: String) -> [(label: String, weight: Double)] {
        return groupData(from: weightData.map { (date: $0.date, value: $0.weight) },
                         days: days,
                         interval: interval,
                         inputDateFormat: inputDateFormat,
                         outputDateFormat: outputDateFormat)
        .map { (label: $0.label, weight: $0.aggregatedValue) }
    }
    
    static func groupStepsData(from stepsData: [(date: String, steps: Int)],
                               days: Int,
                               interval: Int,
                               inputDateFormat: String = "yyyy-MM-dd",
                               outputDateFormat: String) -> [(label: String, steps: Int)] {
        let doubleData = stepsData.map { (date: $0.date, value: Double($0.steps)) }
        let grouped = groupData(from: doubleData, days: days, interval: interval, inputDateFormat: inputDateFormat, outputDateFormat: outputDateFormat)
        return grouped.map { (label: $0.label, steps: Int($0.aggregatedValue)) }
    }
    
    static func groupBurnedCaloriesData(from burnedCaloriesData: [(date: String, burnedCalories: Double)],
                                        days: Int,
                                        interval: Int,
                                        inputDateFormat: String = "yyyy-MM-dd",
                                        outputDateFormat: String) -> [(label: String, burnedCalories: Double)] {
        return groupData(from: burnedCaloriesData.map { (date: $0.date, value: $0.burnedCalories) },
                         days: days,
                         interval: interval,
                         inputDateFormat: inputDateFormat,
                         outputDateFormat: outputDateFormat)
            .map { (label: $0.label, burnedCalories: $0.aggregatedValue) }
    }
    
    static func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
    
    static func dateToString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func groupCalorieData(from calorieData: [(date: String, calories: Int)],
                                 days: Int,
                                 interval: Int,
                                 inputDateFormat: String = "yyyy-MM-dd",
                                 outputDateFormat: String) -> [(label: String, calories: Int)] {
        let doubleData = calorieData.map { (date: $0.date, value: Double($0.calories)) }
        let grouped = groupData(from: doubleData, days: days, interval: interval, inputDateFormat: inputDateFormat, outputDateFormat: outputDateFormat)
        return grouped.map { (label: $0.label, calories: Int($0.aggregatedValue)) }
    }
}

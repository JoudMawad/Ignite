import Foundation

// ChartDataHelper is a utility struct that provides functions to group and aggregate data
// (such as weight, steps, or calories) into buckets over a period of days.
// This is useful when you want to display daily or periodic averages on a chart.
struct ChartDataHelper {
    
    /// Groups raw data into buckets and aggregates values.
    ///
    /// This generic grouping function takes in raw data (with dates as strings and associated values),
    /// groups the data by a specified interval (e.g., every 7 days), and calculates an aggregated value for each bucket.
    /// If no nonzero value is found for a bucket, it tries to use the most recent nonzero value as a fallback.
    ///
    /// - Parameters:
    ///   - rawData: An array of tuples containing a date string and a corresponding value.
    ///   - days: The total number of days to consider.
    ///   - interval: The size of each bucket in days.
    ///   - inputDateFormat: The date format of the input date strings (default is "yyyy-MM-dd").
    ///   - outputDateFormat: The desired date format for the output labels.
    /// - Returns: An array of tuples containing a formatted date label and the aggregated value for that bucket.
    static func groupData(from rawData: [(date: String, value: Double)],
                          days: Int,
                          interval: Int,
                          inputDateFormat: String = "yyyy-MM-dd",
                          outputDateFormat: String) -> [(label: String, aggregatedValue: Double)] {
        
        // Set up the input date formatter.
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone.current
        
        // Set up the output date formatter.
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputDateFormat
        outputFormatter.locale = Locale.current
        outputFormatter.timeZone = TimeZone.current
        
        // Convert raw data into an array of (Date, value) pairs,
        // making sure each date is normalized to the start of the day.
        let dataPoints: [(date: Date, value: Double)] = rawData.compactMap { entry in
            if let date = inputFormatter.date(from: entry.date) {
                return (date: Calendar.current.startOfDay(for: date), value: entry.value)
            }
            return nil
        }.sorted { $0.date < $1.date }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Calculate the start date by going back 'days' days from today.
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: today) else {
            return []
        }
        
        var groupedData: [(label: String, aggregatedValue: Double)] = []
        var lastKnownNonZero: Double? = nil
        
        // Process each bucket defined by the given interval.
        for offset in stride(from: 0, to: days, by: interval) {
            // Determine the start and end of the current bucket.
            guard let bucketStart = calendar.date(byAdding: .day, value: offset, to: startDate),
                  let bucketEnd = calendar.date(byAdding: .day, value: interval, to: bucketStart) else { continue }
            
            // Filter for nonzero values within this bucket.
            let bucketValues = dataPoints.filter { $0.date >= bucketStart && $0.date < bucketEnd && $0.value != 0.0 }
                                         .map { $0.value }
            
            let aggregatedValue: Double
            if bucketValues.isEmpty {
                // If there are no nonzero values, try to use the last known nonzero value.
                if let last = lastKnownNonZero {
                    aggregatedValue = last
                } else {
                    // If there's no previous nonzero value, search backwards for one.
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
                    // If a nonzero value is found, use it; otherwise, try searching forward.
                    if let found = foundValue {
                        aggregatedValue = found
                        lastKnownNonZero = found
                    } else if let futureNonZeroPoint = dataPoints.first(where: { $0.date >= bucketStart && $0.value != 0.0 }) {
                        aggregatedValue = futureNonZeroPoint.value
                        lastKnownNonZero = futureNonZeroPoint.value
                    } else {
                        aggregatedValue = 0.0
                    }
                }
            } else {
                // If there are nonzero values, calculate the average for the bucket.
                aggregatedValue = bucketValues.reduce(0.0, +) / Double(bucketValues.count)
                lastKnownNonZero = aggregatedValue
            }
            
            // Format the bucket's start date as the label.
            let label = outputFormatter.string(from: bucketStart)
            groupedData.append((label: label, aggregatedValue: aggregatedValue))
        }
        
        return groupedData
    }
    
    /// Groups data and includes buckets even if the data has zero values.
    ///
    /// This function works similarly to `groupData` but does not attempt to substitute missing values;
    /// it simply returns 0 if no data exists in a bucket.
    ///
    /// - Parameters:
    ///   - rawData: An array of tuples with date strings and values.
    ///   - days: The total number of days to consider.
    ///   - interval: The size of each bucket in days.
    ///   - inputDateFormat: The format of the input date strings.
    ///   - outputDateFormat: The desired format for the output labels.
    /// - Returns: An array of tuples with formatted labels and aggregated values.
    static func groupDataIncludingZeros(from rawData: [(date: String, value: Double)],
                                          days: Int,
                                          interval: Int,
                                          inputDateFormat: String = "yyyy-MM-dd",
                                          outputDateFormat: String) -> [(label: String, aggregatedValue: Double)] {
        
        // Set up input and output date formatters (similar to the previous function).
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone.current
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputDateFormat
        outputFormatter.locale = Locale.current
        outputFormatter.timeZone = TimeZone.current
        
        // Parse and sort the raw data into (Date, value) pairs.
        let dataPoints: [(date: Date, value: Double)] = rawData.compactMap { entry in
            if let date = inputFormatter.date(from: entry.date) {
                return (date: Calendar.current.startOfDay(for: date), value: entry.value)
            }
            return nil
        }.sorted { $0.date < $1.date }
        
        let calendar = Calendar.current
        // Calculate the start date by going back 'days' days from today.
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: calendar.startOfDay(for: Date())) else {
            return []
        }
        
        var groupedData: [(label: String, aggregatedValue: Double)] = []
        
        // Process each bucket as defined by the interval.
        for offset in stride(from: 0, to: days, by: interval) {
            guard let bucketStart = calendar.date(byAdding: .day, value: offset, to: startDate),
                  let bucketEnd = calendar.date(byAdding: .day, value: interval, to: bucketStart) else { continue }
            
            // Get all values (including zeros) for this bucket.
            let bucketValues = dataPoints.filter { $0.date >= bucketStart && $0.date < bucketEnd }
                                         .map { $0.value }
            
            // Calculate the average, or use 0 if the bucket is empty.
            let aggregatedValue: Double = bucketValues.isEmpty ? 0.0 : bucketValues.reduce(0.0, +) / Double(bucketValues.count)
            let label = outputFormatter.string(from: bucketStart)
            groupedData.append((label: label, aggregatedValue: aggregatedValue))
        }
        
        return groupedData
    }
    
    /// Groups weight data specifically.
    ///
    /// This function takes in weight data (as date strings and weight values),
    /// groups it using the generic `groupData` function, and then maps the aggregated values back to weight.
    ///
    /// - Parameters:
    ///   - weightData: An array of tuples with date strings and weight values.
    ///   - days: The total number of days to consider.
    ///   - interval: The bucket size in days.
    ///   - inputDateFormat: Format of the input date strings.
    ///   - outputDateFormat: Desired format for the output labels.
    /// - Returns: An array of tuples with formatted labels and aggregated weight values.
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
    
    /// Groups steps data.
    ///
    /// Converts steps from integer values into doubles for processing,
    /// groups the data including buckets with zeros,
    /// then converts the result back to integers.
    ///
    /// - Parameters:
    ///   - stepsData: An array of tuples with date strings and step counts.
    ///   - days: The total number of days to consider.
    ///   - interval: The size of each bucket in days.
    ///   - inputDateFormat: Format of the input date strings.
    ///   - outputDateFormat: Desired format for the output labels.
    /// - Returns: An array of tuples with labels and aggregated step counts.
    static func groupStepsData(from stepsData: [(date: String, steps: Int)],
                               days: Int,
                               interval: Int,
                               inputDateFormat: String = "yyyy-MM-dd",
                               outputDateFormat: String) -> [(label: String, steps: Int)] {
        let doubleData = stepsData.map { (date: $0.date, value: Double($0.steps)) }
        let grouped = groupDataIncludingZeros(from: doubleData,
                                              days: days,
                                              interval: interval,
                                              inputDateFormat: inputDateFormat,
                                              outputDateFormat: outputDateFormat)
        return grouped.map { (label: $0.label, steps: Int($0.aggregatedValue)) }
    }
    
    /// Groups burned calories data.
    ///
    /// Processes burned calories similarly to steps, grouping the data over specified intervals.
    ///
    /// - Parameters:
    ///   - burnedCaloriesData: An array of tuples with date strings and burned calories values.
    ///   - days: The total number of days to consider.
    ///   - interval: The bucket size in days.
    ///   - inputDateFormat: Format of the input date strings.
    ///   - outputDateFormat: Desired format for the output labels.
    /// - Returns: An array of tuples with labels and aggregated burned calories.
    static func groupBurnedCaloriesData(from burnedCaloriesData: [(date: String, burnedCalories: Double)],
                                        days: Int,
                                        interval: Int,
                                        inputDateFormat: String = "yyyy-MM-dd",
                                        outputDateFormat: String) -> [(label: String, burnedCalories: Double)] {
        return groupDataIncludingZeros(from: burnedCaloriesData.map { (date: $0.date, value: $0.burnedCalories) },
                                       days: days,
                                       interval: interval,
                                       inputDateFormat: inputDateFormat,
                                       outputDateFormat: outputDateFormat)
            .map { (label: $0.label, burnedCalories: $0.aggregatedValue) }
    }
    
    /// Converts a date string into a Date object.
    ///
    /// - Parameters:
    ///   - dateString: The date as a string.
    ///   - format: The expected format of the date string (default is "yyyy-MM-dd").
    /// - Returns: A Date object if the conversion is successful; otherwise, nil.
    static func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
    
    /// Converts a Date object into a formatted date string.
    ///
    /// - Parameters:
    ///   - date: The Date object to be formatted.
    ///   - format: The desired format of the date string (default is "yyyy-MM-dd").
    /// - Returns: A formatted date string.
    static func dateToString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    /// Groups calorie data.
    ///
    /// Converts calorie values from integers to doubles for grouping, then maps the aggregated result back to integers.
    ///
    /// - Parameters:
    ///   - calorieData: An array of tuples with date strings and calorie values.
    ///   - days: The total number of days to consider.
    ///   - interval: The bucket size in days.
    ///   - inputDateFormat: Format of the input date strings.
    ///   - outputDateFormat: Desired format for the output labels.
    /// - Returns: An array of tuples with labels and aggregated calorie values.
    static func groupCalorieData(from calorieData: [(date: String, calories: Int)],
                                 days: Int,
                                 interval: Int,
                                 inputDateFormat: String = "yyyy-MM-dd",
                                 outputDateFormat: String) -> [(label: String, calories: Int)] {
        let doubleData = calorieData.map { (date: $0.date, value: Double($0.calories)) }
        let grouped = groupDataIncludingZeros(from: doubleData,
                                              days: days,
                                              interval: interval,
                                              inputDateFormat: inputDateFormat,
                                              outputDateFormat: outputDateFormat)
        return grouped.map { (label: $0.label, calories: Int($0.aggregatedValue)) }
    }
}

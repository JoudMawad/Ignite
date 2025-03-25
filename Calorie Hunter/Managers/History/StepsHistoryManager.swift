import Foundation
import Combine

// This manager handles the storage and retrieval of daily steps history.
// It uses the ObservableObject protocol to notify any views when the data changes.
class StepsHistoryManager: ObservableObject {
    // Shared instance to allow easy access from anywhere in the app.
    static let shared = StepsHistoryManager()
    
    // A unique key to store our daily steps history in UserDefaults.
    private let dailyStepsKey = "dailyStepsHistory"
    
    // Local storage: a dictionary where each key is a date string ("yyyy-MM-dd")
    // and the value is the step count for that day.
    private var localHistory: [String: Int] {
        get {
            // Retrieve the stored dictionary from UserDefaults.
            // If nothing is stored, return an empty dictionary.
            UserDefaults.standard.dictionary(forKey: dailyStepsKey) as? [String: Int] ?? [:]
        }
        set {
            // Save the updated dictionary back to UserDefaults.
            UserDefaults.standard.set(newValue, forKey: dailyStepsKey)
            // Inform any listeners (like SwiftUI views) that the data has changed.
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    /// Imports the fetched steps data into local storage.
    /// - Parameter stepsData: An array of tuples where each tuple contains a date string and the steps count.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        // Start with the current local history.
        var history = localHistory
        // Update the history with the new steps data.
        for entry in stepsData {
            history[entry.date] = entry.steps
        }
        // Save the updated history.
        localHistory = history
    }
    
    /// Returns the step counts for the last given number of days.
    /// - Parameter days: The number of days to retrieve.
    /// - Returns: An array of tuples (date, steps) in chronological order.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        var results: [(String, Int)] = []
        // Create a date formatter to convert dates into a "yyyy-MM-dd" string.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        // For each day in the period...
        for i in 0..<days {
            // Calculate the date 'i' days ago.
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                // Format the date into a string.
                let dateString = formatter.string(from: date)
                // Retrieve the step count for that day, defaulting to 0 if no record exists.
                let count = localHistory[dateString] ?? 0
                // Add the result to the array.
                results.append((dateString, count))
            }
        }
        // Reverse the results so that the oldest date comes first.
        return results.reversed()
    }
    
    /// Clears all locally stored steps data.
    func clearData() {
        localHistory = [:]
    }
}

import Foundation
import Combine

class StepsHistoryManager: ObservableObject {
    static let shared = StepsHistoryManager()
    
    private let dailyStepsKey = "dailyStepsHistory"
    
    /// Local storage: a dictionary where the key is a date string ("yyyy-MM-dd") and the value is the step count.
    private var localHistory: [String: Int] {
        get {
            UserDefaults.standard.dictionary(forKey: dailyStepsKey) as? [String: Int] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyStepsKey)
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    /// Imports the fetched steps data into local storage.
    /// - Parameter stepsData: An array of (date, steps) tuples.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        var history = localHistory
        for entry in stepsData {
            history[entry.date] = entry.steps
        }
        localHistory = history
    }
    
    /// Returns step counts for the last `days` days.
    /// - Parameter days: Number of days to retrieve.
    /// - Returns: An array of (date, steps) tuples in chronological order.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        var results: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                let count = localHistory[dateString] ?? 0
                results.append((dateString, count))
            }
        }
        return results.reversed()
    }
    
    /// Clears the locally stored steps data.
    func clearData() {
        localHistory = [:]
    }
}

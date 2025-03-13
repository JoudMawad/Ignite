import Foundation
import Combine

class StepsHistoryManager: ObservableObject {
    static let shared = StepsHistoryManager()
    
    private let dailyStepsKey = "dailyStepsHistory"
    
    /// Local storage of steps keyed by date string "yyyy-MM-dd"
    private var localHistory: [String: Int] {
        get {
            UserDefaults.standard.dictionary(forKey: dailyStepsKey) as? [String: Int] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyStepsKey)
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    /// Imports historical step counts.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        var history = localHistory
        for entry in stepsData {
            history[entry.date] = entry.steps
        }
        localHistory = history
    }
    
    /// Returns step counts for the last `days` days.
    /// This method now uses a date formatter with an explicit time zone.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        var results: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Ensure both storing and retrieval use the same time zone.
        formatter.timeZone = TimeZone.current
        
        // Loop through each day in the past `days`.
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                let count = localHistory[dateString] ?? 0
                results.append((dateString, count))
            }
        }
        return results.reversed()
    }
    
    /// Optional: method to clear stored data for testing.
    func clearData() {
        localHistory = [:]
    }
}

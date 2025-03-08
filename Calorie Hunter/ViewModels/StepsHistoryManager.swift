import Foundation
import Combine

class StepsHistoryManager: ObservableObject {
    static let shared = StepsHistoryManager()
    
    private let dailyStepsKey = "dailyStepsHistory"
    
    /// The local dictionary of [String: Int], keyed by date (e.g., "2025-03-10"), with the step count as the value.
    private var localHistory: [String: Int] {
        get {
            UserDefaults.standard.dictionary(forKey: dailyStepsKey) as? [String: Int] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyStepsKey)
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    /// Imports historical step counts without overwriting existing entries.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        var history = localHistory
        for entry in stepsData {
            // If there's already an entry for that date, keep it
            if history[entry.date] == nil {
                history[entry.date] = entry.steps
            }
        }
        localHistory = history
    }
    
    /// Returns step counts for the last X days, in ascending date order.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        var results: [(String, Int)] = []
        for i in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dateString = formatDate(date)
            if let count = localHistory[dateString] {
                results.append((dateString, count))
            }
        }
        // results is in descending order (today to oldest). Reverse it if you want oldest-to-newest.
        return results.reversed()
    }
    
    /// Formats a Date as "yyyy-MM-dd".
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

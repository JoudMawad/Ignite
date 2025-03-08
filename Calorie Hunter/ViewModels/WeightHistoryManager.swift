import Foundation
import Combine

class WeightHistoryManager: ObservableObject {
    static let shared = WeightHistoryManager()
    
    // UserDefaults keys.
    private let lastSavedDateKey = "lastWeightSavedDate"
    private let dailyWeightKey = "dailyWeightHistory"
    
    // Local history is stored as a dictionary [String: Double].
    private var localHistory: [String: Double] {
        get {
            UserDefaults.standard.dictionary(forKey: dailyWeightKey) as? [String: Double] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyWeightKey)
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    /// Saves the current weight for today.
    func saveDailyWeight(currentWeight: Double) {
        let today = formatDate(Date())
        var history = localHistory
        history[today] = currentWeight
        localHistory = history
    }
    
    /// Imports historical weights from HealthKit (merging without overwriting existing entries).
    func importHistoricalWeights(_ weights: [(date: String, weight: Double)]) {
        var history = localHistory
        for entry in weights {
            if history[entry.date] == nil {
                history[entry.date] = entry.weight
            }
        }
        localHistory = history
    }
    
    /// Exports the local history as CSV text.
    func exportWeightHistoryToCSV() -> String {
        let history = localHistory
        var csvString = "Date,Weight (kg)\n"
        for (date, weight) in history.sorted(by: { $0.key < $1.key }) {
            csvString += "\(date),\(weight)\n"
        }
        return csvString
    }
    
    /// Returns weight entries for the past 'days' days.
    func weightForPeriod(days: Int) -> [(date: String, weight: Double)] {
        var result: [(String, Double)] = []
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                if let weight = localHistory[dateString] {
                    result.append((date: dateString, weight: weight))
                }
            }
        }
        return result.reversed()
    }
    
    /// Formats a Date as "yyyy-MM-dd".
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

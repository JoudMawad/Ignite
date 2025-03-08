import SwiftUI

class StepsViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let stepsManager = StepsHistoryManager.shared
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                // After authorization, import historical steps
                self.importHistoricalStepsFromHealthKit()
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    /// Example: fetch the last year of data.
    /// For debugging, consider fetching a smaller range (like 7 days).
    func importHistoricalStepsFromHealthKit() {
        // Start and end date for your fetch. Adjust as needed:
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            
            // 1. Print the raw data from HealthKit (debug):
            print("=== RAW DATA FROM HEALTHKIT ===")
            for (dateStr, steps) in stepsData {
                print("\(dateStr): \(steps)")
            }
            
            // 2. Save them locally
            self.stepsManager.importHistoricalSteps(stepsData)
            
            // 3. Read them back & print so you know they're stored:
            let localDict = UserDefaults.standard.dictionary(forKey: "dailyStepsHistory") as? [String: Int] ?? [:]
            print("=== AFTER IMPORT, localDict has \(localDict.count) entries ===")
            for (date, count) in localDict {
                print("Stored: \(date) -> \(count)")
            }
        }
    }
}

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
                // Handle auth failure
            }
        }
    }
    
    func importHistoricalStepsFromHealthKit() {
        // For example, fetch the last year of data
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            // Save them locally
            self.stepsManager.importHistoricalSteps(stepsData)
        }
    }
}

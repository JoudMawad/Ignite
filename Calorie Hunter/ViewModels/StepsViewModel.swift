import SwiftUI
import Combine

class StepsViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let stepsManager = StepsHistoryManager.shared
    private var timerCancellable: AnyCancellable?
    
    @Published var currentSteps: Int = 0
    
    init() {
        requestAuthorization()
        startStepUpdates()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalStepsFromHealthKit()
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func importHistoricalStepsFromHealthKit() {
        // Example: fetch the last year of data.
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            self.stepsManager.importHistoricalSteps(stepsData)
        }
    }
    
    /// This function sets up a timer to update the current steps every 1 second.
    private func startStepUpdates() {
        timerCancellable = Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Fetch today's steps (using days: 1 returns an array with today's entry)
                self.currentSteps = self.stepsManager.stepsForPeriod(days: 1).first?.steps ?? 0
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

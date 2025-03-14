import SwiftUI
import Combine

class StepsViewModel: ObservableObject {
    // Use the shared HealthKitManager for authorization.
    private let healthKitManager = HealthKitManager.shared
    // Use a dedicated StepsManager for fetching HealthKit data.
    private let stepsManager = StepsManager()
    private var timerCancellable: AnyCancellable?
    
    @Published var currentSteps: Int = 0
    
    init() {
        // Load the stored value (or 0 if not yet stored)
        self.currentSteps = UserDefaults.standard.integer(forKey: "steps")
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
        
        stepsManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            // Update the shared StepsHistoryManager so the charts and view model have up-to-date data.
            StepsHistoryManager.shared.importHistoricalSteps(stepsData)
            print("DEBUG: Imported historical steps from HealthKit into StepsHistoryManager.")
        }
    }
    
    /// Updates the current steps value both in persistent storage and in the published property.
    private func updateSteps(with newValue: Int) {
        // Persist the new value.
        UserDefaults.standard.set(newValue, forKey: "steps")
        DispatchQueue.main.async {
            self.currentSteps = newValue
        }
    }
    
    /// Periodically fetch today's steps from the shared StepsHistoryManager and update the view model.
    private func startStepUpdates() {
        timerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Use the shared StepsHistoryManager to retrieve today's steps.
                let steps = StepsHistoryManager.shared.stepsForPeriod(days: 1).first?.steps ?? 0
                self.updateSteps(with: steps)
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

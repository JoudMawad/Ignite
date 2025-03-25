import SwiftUI
import Combine

// ViewModel for managing weight data, conforming to ObservableObject to support SwiftUI bindings.
class WeightViewModel: ObservableObject {
    // Shared HealthKit manager instance for handling authorization and data fetching.
    private let healthKitManager = HealthKitManager.shared
    // Instance of WeightManager to handle weight-specific operations.
    private let weightManager = WeightManager()
    
    // Published property to update the UI when the current weight changes.
    @Published var currentWeight: Double = 0.0
    
    // Initializer that loads the last saved weight from UserDefaults, requests authorization, and sets up a day change observer.
    init() {
        // Retrieve the current weight from persistent storage.
        self.currentWeight = UserDefaults.standard.double(forKey: "weight")
        // Request authorization to access HealthKit data.
        requestAuthorization()
        // Register for notifications to handle significant time changes (typically at day boundaries).
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDayChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
        // Perform an initial update of the weight from historical data.
        updateWeightFromHistory()
    }
    
    // MARK: - HealthKit Authorization and Data Import
    
    // Requests HealthKit authorization and, if successful, initiates the historical data import.
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalWeightsFromHealthKit()
            }
        }
    }
    
    // Imports all historical weight data from HealthKit.
    // It defines the time range from the distant past until now.
    func importHistoricalWeightsFromHealthKit() {
        let startDate = Date.distantPast
        let endDate = Date()
        
        // Fetch historical daily weights and delegate importing to the WeightHistoryManager.
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { weightData in
            WeightHistoryManager.shared.importHistoricalWeights(weightData)
        }
    }
    
    // MARK: - Weight Updates and Persistence
    
    // Updates the current weight both in memory and in UserDefaults.
    private func updateWeight(with newValue: Double) {
        UserDefaults.standard.set(newValue, forKey: "weight")
        DispatchQueue.main.async {
            self.currentWeight = newValue
        }
    }
    
    // Called when a significant time change occurs (e.g., at midnight) to refresh weight data.
    @objc private func handleDayChange() {
        updateWeightFromHistory()
    }
    
    // Retrieves the latest weight data for the past day and updates the current weight.
    private func updateWeightFromHistory() {
        // Fetch the weight for the past day; if no data is found, defaults to 0.0.
        let weight = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
        updateWeight(with: weight)
    }
    
    // Removes the observer on deinitialization to prevent memory leaks.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

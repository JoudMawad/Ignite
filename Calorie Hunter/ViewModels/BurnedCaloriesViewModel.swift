import Foundation
import Combine

// BurnedCaloriesViewModel is responsible for managing burned calories data from HealthKit,
// importing historical data, updating cumulative totals, and exposing the current value
// for SwiftUI views to observe.
class BurnedCaloriesViewModel: ObservableObject {
    // Reference to the HealthKit manager that fetches burned calories data.
    private let healthKitManager = BurnedCaloriesManager.shared
    // Reference to the history manager that stores and retrieves historical burned calories.
    private let historyManager = BurnedCaloriesHistoryManager.shared
    
    // Published property so that UI views update when the current cumulative calories change.
    @Published var currentBurnedCalories: Double = 0

    init() {
        // Request HealthKit authorization at initialization.
        requestAuthorization()
        
        // Start observing HealthKit for any immediate changes in burned calories.
        BurnedCaloriesManager.shared.startObservingBurnedCaloriesChanges()
        
        // Listen for notifications when HealthKit's burned calories data changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitDataChanged(notification:)),
                                               name: .healthKitBurnedCaloriesDataChanged,
                                               object: nil)
        // Load any previously stored cumulative burned calories value from UserDefaults.
        self.currentBurnedCalories = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
    }
    
    /// Called when a HealthKit data change notification is received.
    /// It extracts the latest burned calories from the notification, or falls back to today's value.
    @objc private func handleHealthKitDataChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
           let latestCalories = userInfo["latestCalories"] as? Double {
            updateCumulativeCalories(with: latestCalories)
        } else {
            // Fallback: if the notification doesn't include a new value, get today's calories from history.
            let todayCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
            updateCumulativeCalories(with: todayCalories)
        }
    }
    
    /// Requests HealthKit authorization.
    /// On success, it triggers the import of historical burned calories data.
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalBurnedCaloriesFromHealthKit()
            } else {
                // Handle the error as needed (e.g., log or show an alert).
            }
        }
    }
    
    /// Imports historical burned calories from HealthKit for the past year.
    /// This data is then stored using the history manager.
    func importHistoricalBurnedCaloriesFromHealthKit() {
        // Define the date range for historical data (last 1 year).
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailyBurnedCalories(startDate: startDate, endDate: endDate) { caloriesData in
            self.historyManager.importHistoricalBurnedCalories(caloriesData)
        }
    }
    
    /// Updates the cumulative burned calories value using a delta approach.
    ///
    /// This method reads the previous cumulative total and the last recorded today's value,
    /// computes the difference (delta) from the new value, and updates both the cumulative total
    /// and the last today's value in UserDefaults.
    /// Finally, it updates the published property so that the UI reflects the new total.
    private func updateCumulativeCalories(with newValue: Double) {
        let previousCumulative = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
        let lastTodayValue = UserDefaults.standard.double(forKey: "lastTodayBurnedCalories")
        
        // Calculate the difference from the last known value.
        let delta = newValue - lastTodayValue
        // Update the cumulative total by adding the difference.
        let updatedTotal = previousCumulative + delta
        
        // Save the new cumulative total and the latest today's value.
        UserDefaults.standard.set(updatedTotal, forKey: "cumulativeBurnedCalories")
        UserDefaults.standard.set(newValue, forKey: "lastTodayBurnedCalories")
        
        // Update the published property on the main thread so UI updates correctly.
        DispatchQueue.main.async {
            self.currentBurnedCalories = updatedTotal
        }
    }
    
    // Remove the view model as an observer when it's deallocated.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

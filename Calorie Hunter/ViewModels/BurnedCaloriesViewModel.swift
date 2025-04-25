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
            DispatchQueue.main.async {
                // Prevent duplicate updates
                guard self.currentBurnedCalories != latestCalories else { return }
                self.currentBurnedCalories = latestCalories
            }
        } else {
            let todayCalories = self.historyManager.burnedCalories(on: Date())
            DispatchQueue.main.async {
                // Prevent duplicate updates
                guard self.currentBurnedCalories != todayCalories else { return }
                self.currentBurnedCalories = todayCalories
            }
        }
    }
    
    /// Requests HealthKit authorization.
    /// On success, it triggers the import of historical burned calories data.
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                // Import past year of data, then fetch today's latest burned calories.
                self.importHistoricalBurnedCaloriesFromHealthKit()
                BurnedCaloriesManager.shared.fetchLatestBurnedCalories { latest in
                    DispatchQueue.main.async {
                        // Only update if value has changed
                        guard self.currentBurnedCalories != latest else { return }
                        self.currentBurnedCalories = latest
                    }
                }
            } else {
                // HealthKit not available or denied: fallback to local history.
                let manualCalories = self.historyManager.burnedCalories(on: Date())
                DispatchQueue.main.async {
                    self.currentBurnedCalories = manualCalories
                }
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
    
    // Remove the view model as an observer when it's deallocated.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

import Foundation
import Combine

class BurnedCaloriesViewModel: ObservableObject {
    private let healthKitManager = BurnedCaloriesManager.shared
    private let historyManager = BurnedCaloriesHistoryManager.shared
    
    @Published var currentBurnedCalories: Double = 0

    init() {
        requestAuthorization()
        // Start observing immediate changes.
        BurnedCaloriesManager.shared.startObservingBurnedCaloriesChanges()
        
        // Observe notifications with the latest calories.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitDataChanged(notification:)),
                                               name: .healthKitBurnedCaloriesDataChanged,
                                               object: nil)
        // Load any previously stored cumulative value.
        self.currentBurnedCalories = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
    }
    
    @objc private func handleHealthKitDataChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
           let latestCalories = userInfo["latestCalories"] as? Double {
            updateCumulativeCalories(with: latestCalories)
        } else {
            // Fallback in case no latest value is provided.
            let todayCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
            updateCumulativeCalories(with: todayCalories)
        }
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalBurnedCaloriesFromHealthKit()
            } else {
                // Handle authorization error if needed.
            }
        }
    }
    
    func importHistoricalBurnedCaloriesFromHealthKit() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailyBurnedCalories(startDate: startDate, endDate: endDate) { caloriesData in
            self.historyManager.importHistoricalBurnedCalories(caloriesData)
        }
    }
    
    // Update cumulative calories using the delta approach.
    private func updateCumulativeCalories(with newValue: Double) {
        let previousCumulative = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
        let lastTodayValue = UserDefaults.standard.double(forKey: "lastTodayBurnedCalories")
        
        let delta = newValue - lastTodayValue
        let updatedTotal = previousCumulative + delta
        
        UserDefaults.standard.set(updatedTotal, forKey: "cumulativeBurnedCalories")
        UserDefaults.standard.set(newValue, forKey: "lastTodayBurnedCalories")
        
        DispatchQueue.main.async {
            self.currentBurnedCalories = updatedTotal
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

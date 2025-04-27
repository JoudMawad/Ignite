import Foundation
import Combine

class BurnedCaloriesViewModel: ObservableObject {
    private let healthKitManager = BurnedCaloriesManager.shared
    private let historyManager = BurnedCaloriesHistoryManager.shared
    
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
        // Load the latest burned calories value for today from Core Data.
        self.currentBurnedCalories = historyManager.burnedCalories(on: Date())
    }
    
    @objc private func handleHealthKitDataChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
           let latestCalories = userInfo["latestCalories"] as? Double {
            DispatchQueue.main.async {
                guard self.currentBurnedCalories != latestCalories else { return }
                self.currentBurnedCalories = latestCalories
            }
        } else {
            let todayCalories = self.historyManager.burnedCalories(on: Date())
            DispatchQueue.main.async {
                guard self.currentBurnedCalories != todayCalories else { return }
                self.currentBurnedCalories = todayCalories
            }
        }
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalBurnedCaloriesFromHealthKit()
                BurnedCaloriesManager.shared.fetchLatestBurnedCalories { latest in
                    DispatchQueue.main.async {
                        guard self.currentBurnedCalories != latest else { return }
                        self.currentBurnedCalories = latest
                    }
                }
            } else {
                let manualCalories = self.historyManager.burnedCalories(on: Date())
                DispatchQueue.main.async {
                    self.currentBurnedCalories = manualCalories
                }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

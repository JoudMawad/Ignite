import Foundation
import Combine

class BurnedCaloriesViewModel: ObservableObject {
    private let healthKitManager = BurnedCaloriesManager.shared
    private let historyManager = BurnedCaloriesHistoryManager.shared
    private var timerCancellable: AnyCancellable?
    
    @Published var currentBurnedCalories: Double = 0

    init() {
        requestAuthorization()
        startBurnedCaloriesUpdates() // Periodic refresh to update the cumulative total
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitDataChanged),
                                               name: .healthKitBurnedCaloriesDataChanged,
                                               object: nil)
        // Load any previously stored cumulative value at launch.
        self.currentBurnedCalories = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
    }
    
    @objc private func handleHealthKitDataChanged() {
        let todayCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
        updateCumulativeCalories(with: todayCalories)
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
    
    /// Updates the cumulative calories using persistent storage.
    /// - Parameter newValue: The current burned calories value for today.
    private func updateCumulativeCalories(with newValue: Double) {
        let previousCumulative = UserDefaults.standard.double(forKey: "cumulativeBurnedCalories")
        let lastTodayValue = UserDefaults.standard.double(forKey: "lastTodayBurnedCalories")
        
        let delta = newValue - lastTodayValue
        
        // Update cumulative total with delta (can be positive or negative)
        let updatedTotal = previousCumulative + delta
        
        UserDefaults.standard.set(updatedTotal, forKey: "cumulativeBurnedCalories")
        UserDefaults.standard.set(newValue, forKey: "lastTodayBurnedCalories")
        
        DispatchQueue.main.async {
            self.currentBurnedCalories = updatedTotal
        }
    }
    
    /// Updates today's burned calories every 10 seconds.
    private func startBurnedCaloriesUpdates() {
        timerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let todayCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
                self.updateCumulativeCalories(with: todayCalories)
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

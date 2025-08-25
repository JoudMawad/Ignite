import Foundation
import Combine
import HealthKit
import UIKit

class BurnedCaloriesViewModel: ObservableObject {
    private let healthKitManager = BurnedCaloriesManager.shared
    private let historyManager = BurnedCaloriesHistoryManager.shared
    
    @Published var currentBurnedCalories: Double = 0
    private let healthStore = HKHealthStore()
    private var foregroundObserver: NSObjectProtocol?

    init() {
        // Request HealthKit authorization at initialization.
        requestAuthorization()
        
        // Listen for notifications when HealthKit's burned calories data changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitDataChanged(notification:)),
                                               name: .healthKitBurnedCaloriesDataChanged,
                                               object: nil)
        // Don't load the latest burned calories value for today from Core Data to avoid showing stale values.
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) { [weak self] _ in
            self?.fetchTodayActiveEnergyViaCollection { total in
                DispatchQueue.main.async { self?.currentBurnedCalories = total }
            }
        }
    }
    
    @objc private func handleHealthKitDataChanged(notification: Notification) {
        // Always recompute Today from the daily bucket so it matches the Health app
        fetchTodayActiveEnergyViaCollection { total in
            DispatchQueue.main.async {
                guard self.currentBurnedCalories != total else { return }
                self.currentBurnedCalories = total
            }
        }
    }
    
    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async { self.currentBurnedCalories = 0 }
            return
        }
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalBurnedCaloriesFromHealthKit()
                self.fetchTodayActiveEnergyViaCollection { total in
                    DispatchQueue.main.async {
                        guard self.currentBurnedCalories != total else { return }
                        self.currentBurnedCalories = total
                    }
                }
                BurnedCaloriesManager.shared.startObservingBurnedCaloriesChanges()
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
            let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = .current
            let todayKey = fmt.string(from: Date())
            let finalized = caloriesData.filter { $0.date < todayKey }
            self.historyManager.importHistoricalBurnedCalories(finalized)
        }
    }
    
    private func fetchTodayActiveEnergyViaCollection(completion: @escaping (Double) -> Void) {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0); return
        }
        let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: Date())
        var interval = DateComponents(); interval.day = 1

        let q = HKStatisticsCollectionQuery(quantityType: energyType,
                                            quantitySamplePredicate: nil,
                                            options: .cumulativeSum,
                                            anchorDate: startOfDay,
                                            intervalComponents: interval)

        q.initialResultsHandler = { _, results, _ in
            guard let results else { completion(0); return }
            var total = 0.0
            results.enumerateStatistics(from: startOfDay, to: Date()) { stats, _ in
                total = stats.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            }
            completion(total)
        }

        healthStore.execute(q)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = foregroundObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

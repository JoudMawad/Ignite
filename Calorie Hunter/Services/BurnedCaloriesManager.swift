import HealthKit
import Foundation

// Extend Notification.Name to include a custom notification for when HealthKit's burned calories data changes.
extension Notification.Name {
    static let healthKitBurnedCaloriesDataChanged = Notification.Name("healthKitBurnedCaloriesDataChanged")
}

// BurnedCaloriesManager is a singleton that handles HealthKit interactions for active energy (burned calories).
final class BurnedCaloriesManager {
    // Shared instance to allow global access.
    static let shared = BurnedCaloriesManager()
    // HealthKit store used for all HealthKit queries.
    let healthStore = HKHealthStore()
    
    // Private initializer ensures this class is used as a singleton.
    private init() { }
    
    /// Requests authorization from the user to read active energy burned data.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        let typesToRead: Set<HKObjectType> = [activeEnergyType]
        let typesToShare: Set<HKSampleType> = []
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    /// Fetches historical burned calories data grouped by day.
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void)
    {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.autoupdatingCurrent.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: caloriesType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard error == nil else {
                completion([])
                return
            }
            var dailyBurnedCalories: [(date: String, burnedCalories: Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                if let sumQuantity = statistics.sumQuantity() {
                    let burnedCalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: burnedCalories))
                } else {
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: 0))
                }
            }
            completion(dailyBurnedCalories)
        }
        healthStore.execute(query)
    }
    
    /// Fetches the latest burned calories from the start of today until now.
    func fetchLatestBurnedCalories(completion: @escaping (Double) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: Date())
        var interval = DateComponents(); interval.day = 1
        let q = HKStatisticsCollectionQuery(quantityType: caloriesType,
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
    
    /// Sets up an observer query to watch for any changes in burned calories data.
    func startObservingBurnedCaloriesChanges() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        healthStore.enableBackgroundDelivery(for: caloriesType, frequency: .immediate) { _, _ in }

        let query = HKObserverQuery(sampleType: caloriesType, predicate: nil) { [weak self] _, completionHandler, _ in
            guard let self = self else { completionHandler(); return }
            self.fetchLatestBurnedCalories { latestCalories in
                NotificationCenter.default.post(name: .healthKitBurnedCaloriesDataChanged,
                                                object: nil,
                                                userInfo: ["latestCalories": latestCalories])
                completionHandler()
            }
        }
        healthStore.execute(query)
    }
}

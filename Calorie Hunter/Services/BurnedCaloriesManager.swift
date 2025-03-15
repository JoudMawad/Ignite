import HealthKit
import Foundation

extension Notification.Name {
    static let healthKitBurnedCaloriesDataChanged = Notification.Name("healthKitBurnedCaloriesDataChanged")
}

final class BurnedCaloriesManager {
    static let shared = BurnedCaloriesManager()
    let healthStore = HKHealthStore()
    
    private init() { }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [activeEnergyType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void)
    {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
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
    
    // New: Fetch the latest burned calories from the start of today until now.
    func fetchLatestBurnedCalories(completion: @escaping (Double) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let sampleQuery = HKSampleQuery(sampleType: caloriesType,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            let totalCalories = samples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            }
            completion(totalCalories)
        }
        
        healthStore.execute(sampleQuery)
    }
    
    // Updated: Use an observer query to fetch the latest burned calories immediately.
    func startObservingBurnedCaloriesChanges() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let query = HKObserverQuery(sampleType: caloriesType, predicate: nil) { [weak self] _, completionHandler, _ in
            guard let self = self else {
                completionHandler()
                return
            }
            
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

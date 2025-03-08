import HealthKit

extension Notification.Name {
    static let healthKitWeightDataChanged = Notification.Name("healthKitWeightDataChanged")
}

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // 1) Define the types we want to read from HealthKit
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [bodyMassType, stepType]
        
        // 2) Request authorization for all these read types
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    
    func fetchLatestWeight(completion: @escaping (Double?) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard error == nil,
                  let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weightInKg)
        }
        healthStore.execute(query)
    }
    
    func fetchHistoricalDailyWeights(startDate: Date, endDate: Date, completion: @escaping ([(date: String, weight: Double)]) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: weightType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard error == nil else {
                completion([])
                return
            }
            var dailyWeights: [(date: String, weight: Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.averageQuantity() {
                    let weight = quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    let dateStr = formatter.string(from: statistics.startDate)
                    dailyWeights.append((date: dateStr, weight: weight))
                }
            }
            completion(dailyWeights)
        }
        healthStore.execute(query)
    }
    
    func startObservingWeightChanges() {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        let query = HKObserverQuery(sampleType: weightType, predicate: nil) { _, completionHandler, _ in
            NotificationCenter.default.post(name: .healthKitWeightDataChanged, object: nil)
            completionHandler()
        }
        healthStore.execute(query)
    }
    
    func fetchHistoricalDailySteps(startDate: Date,
                                   endDate: Date,
                                   completion: @escaping ([(date: String, steps: Int)]) -> Void)
    {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        // We'll sum step counts daily.
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            guard error == nil else {
                completion([])
                return
            }
            
            var dailySteps: [(date: String, steps: Int)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            // Enumerate over each day from startDate to endDate.
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                if let sumQuantity = statistics.sumQuantity() {
                    // Convert to an integer step count
                    let stepCount = Int(sumQuantity.doubleValue(for: .count()))
                    let dateStr = formatter.string(from: statistics.startDate)
                    dailySteps.append((date: dateStr, steps: stepCount))
                }
            })
            completion(dailySteps)
        }
        
        healthStore.execute(query)
    }
}

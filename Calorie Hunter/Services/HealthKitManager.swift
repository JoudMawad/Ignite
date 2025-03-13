import HealthKit
import Foundation

extension Notification.Name {
    static let healthKitWeightDataChanged = Notification.Name("healthKitWeightDataChanged")
    static let healthKitBurnedCaloriesDataChanged = Notification.Name("healthKitBurnedCaloriesDataChanged")
}

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Define the types we want to read: body mass, step count, and active energy burned.
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [bodyMassType, stepType, activeEnergyType]
        
        // Request authorization for these read types.
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Weight Functions
    
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
    
    func fetchHistoricalDailyWeights(startDate: Date,
                                     endDate: Date,
                                     completion: @escaping ([(date: String, weight: Double)]) -> Void)
    {
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
    
    // MARK: - Steps Functions
    
    func fetchHistoricalDailySteps(startDate: Date,
                                   endDate: Date,
                                   completion: @escaping ([(date: String, steps: Int)]) -> Void)
    {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("DEBUG: .stepCount is not available on this device. Returning empty.")
            completion([])
            return
        }
        
        print("DEBUG: Starting daily steps fetch from \(startDate) to \(endDate)")
        
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        // We'll sum step counts daily.
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                print("DEBUG: fetch error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            print("DEBUG: fetch succeeded, enumerating results...")
            var dailySteps: [(date: String, steps: Int)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            // Enumerate over each day from startDate to endDate.
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                
                if let sumQuantity = statistics.sumQuantity() {
                    let stepCount = Int(sumQuantity.doubleValue(for: .count()))
                    dailySteps.append((date: dateStr, steps: stepCount))
                    print("DEBUG: date=\(dateStr), steps=\(stepCount)")
                } else {
                    dailySteps.append((date: dateStr, steps: 0))
                    print("DEBUG: date=\(dateStr), steps=0 (no sumQuantity)")
                }
            })
            
            print("DEBUG: dailySteps final count = \(dailySteps.count)")
            completion(dailySteps)
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Burned Calories Functions
    
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void)
    {
        guard let burnedCaloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: burnedCaloriesType,
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
    
    func startObservingBurnedCaloriesChanges() {
        guard let burnedCaloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let query = HKObserverQuery(sampleType: burnedCaloriesType, predicate: nil) { _, completionHandler, _ in
            NotificationCenter.default.post(name: .healthKitBurnedCaloriesDataChanged, object: nil)
            completionHandler()
        }
        healthStore.execute(query)
    }
}

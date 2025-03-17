import HealthKit
import Foundation

extension Notification.Name {
    static let healthKitWeightDataChanged = Notification.Name("healthKitWeightDataChanged")
}

final class WeightManager {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore = HealthKitManager.shared.healthStore) {
        self.healthStore = healthStore
    }
    
    // Now returns a tuple with weight and sample's endDate.
    func fetchLatestWeight(completion: @escaping ((weight: Double, date: Date)?) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, samples, error in
            if error != nil {
                completion(nil)
                return
            }
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion((weight: weightInKg, date: sample.endDate))
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
            if error != nil {
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
}

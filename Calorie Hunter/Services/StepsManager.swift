import HealthKit
import Foundation

final class StepsManager {
    private let healthStore: HKHealthStore
    private var importedSteps: [(date: String, steps: Int)] = []
    
    init(healthStore: HKHealthStore = HealthKitManager.shared.healthStore) {
        self.healthStore = healthStore
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
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                  quantitySamplePredicate: nil,
                                                  options: .cumulativeSum,
                                                  anchorDate: anchorDate,
                                                  intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            
            var dailySteps: [(date: String, steps: Int)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                if let sumQuantity = statistics.sumQuantity() {
                    let stepCount = Int(sumQuantity.doubleValue(for: .count()))
                    dailySteps.append((date: dateStr, steps: stepCount))
                } else {
                    dailySteps.append((date: dateStr, steps: 0))
                }
            })
            
            completion(dailySteps)
        }
        
        self.healthStore.execute(query)
    }
    
    func updateHistoricalSteps(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { fetchedSteps in
            self.importedSteps = fetchedSteps
            StepsHistoryManager.shared.importHistoricalSteps(fetchedSteps)
            completion()
        }
    }
}

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
            print("DEBUG: .stepCount is not available on this device. Returning empty.")
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
            if let error = error {
                print("DEBUG: fetch error: \(error.localizedDescription)")
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
        
        healthStore.execute(query)
    }
    
    /// Imports and stores the historical steps data for later use.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        importedSteps = stepsData
    }
    
    /// Returns the steps for the last 'days' days.
    /// For example, if days == 1, it returns the latest day's steps data.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        // Sort the imported steps in descending order by date.
        // (Assuming the date strings are formatted as "yyyy-MM-dd" so lexicographic sorting works.)
        let sortedSteps = importedSteps.sorted { $0.date > $1.date }
        return Array(sortedSteps.prefix(days))
    }
}

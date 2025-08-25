import HealthKit
import Foundation

// StepsManager is responsible for fetching and updating daily step count data from HealthKit.
final class StepsManager {
    // A reference to HealthKit's health store.
    private let healthStore: HKHealthStore
    // A local array to store imported steps data as tuples (date string and step count).
    private var importedSteps: [(date: String, steps: Int)] = []
    
    // Initialize with a HealthKit store, defaulting to the shared one from HealthKitManager.
    init(healthStore: HKHealthStore = HealthKitManager.shared.healthStore) {
        self.healthStore = healthStore
    }
    
    /// Fetches historical daily step counts from HealthKit between the specified start and end dates.
    /// - Parameters:
    ///   - startDate: The beginning date of the range.
    ///   - endDate: The ending date of the range.
    ///   - completion: A closure returning an array of tuples (date as a string, step count).
    func fetchHistoricalDailySteps(startDate: Date,
                                   endDate: Date,
                                   completion: @escaping ([(date: String, steps: Int)]) -> Void)
    {
        // Get the HealthKit quantity type for step count.
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        // Set up a query interval of one day.
        let interval = DateComponents(day: 1)
        // Use the start of the startDate day as the anchor for the query.
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        // Create a statistics collection query to sum steps over each day.
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                  quantitySamplePredicate: nil,
                                                  options: .cumulativeSum,
                                                  anchorDate: anchorDate,
                                                  intervalComponents: interval)
        
        // This closure is called when the initial query results are available.
        query.initialResultsHandler = { _, results, error in
            // If there's an error, return an empty array.
            if error != nil {
                completion([])
                return
            }
            
            // Prepare an array to store daily step counts.
            var dailySteps: [(date: String, steps: Int)] = []
            // Set up a date formatter to convert dates into "yyyy-MM-dd" strings.
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            // Enumerate over the statistics for each day in the specified range.
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                // Sum the steps for the day, or default to 0 if no data exists.
                if let sumQuantity = statistics.sumQuantity() {
                    let stepCount = Int(sumQuantity.doubleValue(for: .count()))
                    dailySteps.append((date: dateStr, steps: stepCount))
                } else {
                    dailySteps.append((date: dateStr, steps: 0))
                }
            })
            
            // Return the collected daily steps data via the completion handler.
            completion(dailySteps)
        }
        
        // Execute the query on the health store.
        self.healthStore.execute(query)
    }
    
    func fetchHistoricalWalkingDistance(startDate: Date,
                                        endDate: Date,
                                        completion: @escaping ([(date: String, distanceInMeters: Double)]) -> Void)
    {
        guard let distType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchor = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: distType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchor,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard error == nil, let stats = results else {
                completion([])
                return
            }
            var dailyDistances: [(String, Double)] = []
            let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = .current
            stats.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                let dateStr = fmt.string(from: stat.startDate)
                let meters = stat.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                dailyDistances.append((date: dateStr, distanceInMeters: meters))
            }
            completion(dailyDistances)
        }
        healthStore.execute(query)
    }
    
    /// Fetches and imports daily walking/running distances into Core Data.
    /// - Parameters:
    ///   - startDate: The first day to pull data for.
    ///   - endDate: The last day to pull data for.
    ///   - completion: Called when the import is complete.
    func updateHistoricalDistances(startDate: Date,
                                   endDate: Date,
                                   completion: @escaping () -> Void) {
        fetchHistoricalWalkingDistance(startDate: startDate, endDate: endDate) { fetchedDistances in
            // Persist into Core Data via your history manager
            StepsHistoryManager.shared.importHistoricalDistances(fetchedDistances)
            completion()
        }
    }
    
    /// Updates the local historical steps data by fetching new data from HealthKit and saving it.
    /// - Parameters:
    ///   - startDate: The start of the period to update.
    ///   - endDate: The end of the period to update.
    ///   - completion: A closure that is called once the update is complete.
    func updateHistoricalSteps(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        // Fetch historical daily steps in the given date range.
        fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { fetchedSteps in
            // Save the fetched steps to our local variable.
            self.importedSteps = fetchedSteps

            // Exclude today’s steps; only persist finalized days
            let todayKey = {
                let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = .current
                return fmt.string(from: Date())
            }()
            let finalized = fetchedSteps.filter { $0.date < todayKey }

            StepsHistoryManager.shared.importHistoricalSteps(finalized)
            // Call the completion handler to signal that the update is finished.
            completion()
        }
    }
}

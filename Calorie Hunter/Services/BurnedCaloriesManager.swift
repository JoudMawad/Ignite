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
    /// - Parameter completion: A closure called with success status and an optional error.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Get the quantity type for active energy burned.
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
    /// - Parameters:
    ///   - startDate: The starting date for the query.
    ///   - endDate: The ending date for the query.
    ///   - completion: A closure called with an array of tuples (date string, burned calories).
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void)
    {
        // Get the quantity type for active energy burned.
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        // Set the query interval to one day.
        let interval = DateComponents(day: 1)
        // Anchor the query to the start of the day for the start date.
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        // Create a statistics collection query to sum up daily calories.
        let query = HKStatisticsCollectionQuery(quantityType: caloriesType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Handle the initial results of the query.
        query.initialResultsHandler = { _, results, error in
            guard error == nil else {
                completion([])
                return
            }
            
            var dailyBurnedCalories: [(date: String, burnedCalories: Double)] = []
            // Formatter to convert dates into a "yyyy-MM-dd" string.
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            // Enumerate over each day's statistics within the specified range.
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                // If there is a sum available, convert it to kilocalories.
                if let sumQuantity = statistics.sumQuantity() {
                    let burnedCalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: burnedCalories))
                } else {
                    // If no data exists for the day, record 0 calories.
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: 0))
                }
            }
            
            // Return the collected data.
            completion(dailyBurnedCalories)
        }
        
        // Execute the query.
        healthStore.execute(query)
    }
    
    /// Fetches the latest burned calories from the start of today until now.
    /// - Parameter completion: A closure called with the total calories burned.
    func fetchLatestBurnedCalories(completion: @escaping (Double) -> Void) {
        // Get the active energy burned quantity type.
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        // Determine the start of the day.
        let startOfDay = Calendar.current.startOfDay(for: Date())
        // Create a predicate to fetch samples from the start of today until now.
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        // Create a sample query to fetch all calorie samples for today.
        let sampleQuery = HKSampleQuery(sampleType: caloriesType,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            // Sum up all the calories in the samples.
            let totalCalories = samples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            }
            // Active‑energy statistics already include workout calories; return the total directly
            completion(totalCalories)
        }
        // Execute the sample query.
        healthStore.execute(sampleQuery)
    }
    
    /// Sets up an observer query to watch for any changes in burned calories data.
    /// When data changes, it fetches the latest burned calories and posts a notification.
    func startObservingBurnedCaloriesChanges() {
        // Get the quantity type for active energy burned.
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        // Create an observer query without a predicate, so it monitors all changes.
        let query = HKObserverQuery(sampleType: caloriesType, predicate: nil) { [weak self] _, completionHandler, _ in
            // Make sure we have a reference to self.
            guard let self = self else {
                completionHandler()
                return
            }
            
            // Fetch the latest burned calories data.
            self.fetchLatestBurnedCalories { latestCalories in
                // Post a notification with the updated data.
                NotificationCenter.default.post(name: .healthKitBurnedCaloriesDataChanged,
                                                object: nil,
                                                userInfo: ["latestCalories": latestCalories])
                // Signal that the query has completed handling the update.
                completionHandler()
            }
        }
        // Execute the observer query to start monitoring.
        healthStore.execute(query)
    }
}

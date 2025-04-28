import HealthKit
import Foundation

// Extend Notification.Name to add a custom notification for when HealthKit weight data changes.
extension Notification.Name {
    static let healthKitWeightDataChanged = Notification.Name("healthKitWeightDataChanged")
}

// WeightManager is responsible for fetching and observing weight data from HealthKit.
final class WeightManager {
    // A reference to HealthKit's health store, used to execute queries.
    private let healthStore: HKHealthStore
    
    // Initialize with a HealthKit store; by default, we use the shared store from HealthKitManager.
    init(healthStore: HKHealthStore = HealthKitManager.shared.healthStore) {
        self.healthStore = healthStore
    }
    
    /// Fetches the latest recorded weight sample.
    /// - Parameter completion: A closure that returns an optional tuple containing the weight in kilograms and the sample's endDate.
    func fetchLatestWeight(completion: @escaping ((weight: Double, date: Date)?) -> Void) {
        // Get the HealthKit quantity type for body mass.
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }
        // Sort samples by end date in descending order so that the latest sample comes first.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        // Create a sample query that fetches just the most recent weight sample.
        let query = HKSampleQuery(sampleType: weightType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, samples, error in
            if error != nil {
                completion(nil)
                return
            }
            // Make sure we got a valid HKQuantitySample.
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            // Convert the sample's value to kilograms.
            let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            // Return the weight and the sample's end date.
            completion((weight: weightInKg, date: sample.endDate))
        }
        // Execute the query.
        healthStore.execute(query)
    }
    
    /// Fetches historical daily average weight data from HealthKit.
    /// - Parameters:
    ///   - startDate: The start date of the period to fetch data for.
    ///   - endDate: The end date of the period.
    ///   - completion: A closure that returns an array of tuples containing a date string and the corresponding average weight.
    func fetchHistoricalDailyWeights(startDate: Date,
                                     endDate: Date,
                                     completion: @escaping ([(date: String, weight: Double)]) -> Void)
    {
        // Get the HealthKit quantity type for body mass.
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion([])
            return
        }
        // Define a one-day interval for grouping the data.
        let interval = DateComponents(day: 1)
        // Use the start of the startDate as the anchor for the query.
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        // Create a statistics collection query to calculate the average weight per day.
        let query = HKStatisticsCollectionQuery(quantityType: weightType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Handle the results once the query completes.
        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            var dailyWeights: [(date: String, weight: Double)] = []
            // Formatter to convert dates into a "yyyy-MM-dd" string.
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            // Enumerate through the statistics for each day within the specified range.
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.averageQuantity() {
                    // Convert the average quantity to kilograms.
                    let weight = quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    let dateStr = formatter.string(from: statistics.startDate)
                    dailyWeights.append((date: dateStr, weight: weight))
                }
            }
            // Return the daily weight data.
            completion(dailyWeights)
        }
        // Execute the query.
        healthStore.execute(query)
    }
    
    /// Starts observing for any changes in the weight data.
    /// When changes occur, a notification is posted so that other parts of the app can react to the updated data.
    func startObservingWeightChanges() {
        // Get the HealthKit quantity type for body mass.
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        // Create an observer query that listens for changes in the weight data.
        let query = HKObserverQuery(sampleType: weightType, predicate: nil) { _, completionHandler, _ in
            // Post a notification indicating that the weight data has changed.
            NotificationCenter.default.post(name: .healthKitWeightDataChanged, object: nil)
            // Call the completion handler to signal that the update has been processed.
            completionHandler()
        }
        // Execute the observer query.
        healthStore.execute(query)
    }
    
    func saveWeightSample(_ weight: Double,
                            date: Date,
                            completion: @escaping (Bool, Error?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
          completion(false, nil); return
        }
        // 1. Build the HKQuantity & Sample
        let qty = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let sample = HKQuantitySample(
          type: type,
          quantity: qty,
          start: date,
          end: date,
          metadata: nil
        )

        // 2. Save to HealthKit
        healthStore.save(sample) { success, error in
          DispatchQueue.main.async {
            completion(success, error)
          }
        }
      }
}

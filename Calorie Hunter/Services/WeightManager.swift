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
    
    // MARK: - Anchored query storage
    private let weightAnchorDefaultsKey = "HKAnchor.bodyMass"

    private func loadAnchor() -> HKQueryAnchor? {
        guard let data = UserDefaults.standard.data(forKey: weightAnchorDefaultsKey) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
    }

    private func saveAnchor(_ anchor: HKQueryAnchor) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
            UserDefaults.standard.set(data, forKey: weightAnchorDefaultsKey)
        }
    }

    // MARK: - Delta fetch via anchored query
    /// Fetch only new/changed weight samples since the last anchor and store them.
    /// - Parameters:
    ///   - startDate: Optional lower bound to limit how far back the first fetch goes.
    ///   - completion: Called on the main thread after storing samples.
    func fetchWeightDeltasAndStore(since startDate: Date? = nil, completion: (() -> Void)? = nil) {
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyMass) else { completion?(); return }

        let predicate: NSPredicate?
        if let start = startDate {
            predicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: [])
        } else {
            predicate = nil
        }

        let query = HKAnchoredObjectQuery(type: type,
                                          predicate: predicate,
                                          anchor: loadAnchor(),
                                          limit: HKObjectQueryNoLimit) { [weak self] _, samplesOrNil, _, newAnchor, error in
            DispatchQueue.main.async {
                defer { completion?() }
                if let newAnchor = newAnchor { self?.saveAnchor(newAnchor) }
                guard error == nil else { return }
                let samples = (samplesOrNil as? [HKQuantitySample]) ?? []
                if !samples.isEmpty {
                    WeightHistoryManager.shared.applyHealthKitSamples(samples)
                }
            }
        }

        healthStore.execute(query)
    }
    
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
    
    /// Starts observing for weight changes and enables background delivery.
    /// When updates arrive, we fetch only the deltas via an anchored query,
    /// store them into Core Data, then post a notification for the UI layer.
    func startObservingWeightChanges() {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }

        let observer = HKObserverQuery(sampleType: weightType, predicate: nil) { [weak self] _, completionHandler, _ in
            self?.fetchWeightDeltasAndStore() {
                NotificationCenter.default.post(name: .healthKitWeightDataChanged, object: nil)
            }
            // Per Apple guidance, call completionHandler promptly after kicking off work
            completionHandler()
        }

        healthStore.execute(observer)

        // Background delivery so the app gets woken up for new samples
        healthStore.enableBackgroundDelivery(for: weightType, frequency: .immediate) { _, _ in }
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

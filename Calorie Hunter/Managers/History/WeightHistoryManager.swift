import Foundation
import CoreData
import Combine
import HealthKit

// This manager handles saving, fetching, and updating weight history data using Core Data.
// It also imports historical weight data from HealthKit, making it available for your app.
class WeightHistoryManager: ObservableObject {
    // Shared instance to access the manager from anywhere in the app.
    static let shared = WeightHistoryManager()
    
    // The managed object context used for Core Data operations.
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()
    
    // Initialize the manager, defaulting to the shared PersistenceController's view context.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Saves or updates a weight entry for a specific date.
    /// - Parameters:
    ///   - date: The date for which the weight is recorded.
    ///   - weight: The weight value to save (in kilograms).
    ///   - writeToHealthKit: When true, also write the value to HealthKit. Set to false when importing from HealthKit.
    func saveWeight(for date: Date, weight: Double, writeToHealthKit: Bool = false) {
        let day = calendar.startOfDay(for: date)

        let writeCoreData: () -> Void = {
            self.upsertCoreDataWeight(on: day, weight: weight)
        }

        guard writeToHealthKit else {
            writeCoreData()
            return
        }

        WeightManager().saveWeightSample(weight, date: date) { success, error in
            if let error = error { print("HealthKit save error: \(error)") }
            writeCoreData()
        }
    }
    
    /// Imports historical weight data from HealthKit. Does NOT write back to HealthKit.
    /// - Parameter weights: Array of (dateString, kg) using "yyyy-MM-dd" format.
    func importHistoricalWeights(_ weights: [(date: String, weight: Double)]) {
        // Convert to (startOfDay, kg)
        let items: [(day: Date, weight: Double)] = weights.compactMap { entry in
            guard let d = formatter.date(from: entry.date) else { return nil }
            return (calendar.startOfDay(for: d), entry.weight)
        }
        guard let minDay = items.map(\.day).min(),
              let maxDay = items.map(\.day).max() else { return }

        // Fetch existing in one go
        let existing = fetchWeightsDict(from: minDay, to: maxDay)

        for (day, kg) in items {
            if let old = existing[day], old == kg { continue } // unchanged
            saveWeight(for: day, weight: kg, writeToHealthKit: false)
        }
    }
    
    // MARK: - Fetch Weight Entries
    
    /// Fetches weight entries for the past `days` days.
    /// - Parameter days: The number of days to include.
    /// - Returns: An array of tuples, each containing a date string and the weight recorded for that day.
    func weightForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let calendar = self.calendar
        // Calculate the start date for the period.
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) else { return [] }
        
        // Create a fetch request for WeightEntry objects starting from the calculated start date.
        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            // Try to fetch the results from Core Data.
            let results = try context.fetch(fetchRequest)
            let formatter = self.formatter
            // Map the results to an array of tuples with formatted dates and weights.
            return results.map { (date: formatter.string(from: $0.date ?? Date()), weight: $0.weight) }
        } catch {
            // Print an error message if the fetch fails.
            print("Failed to fetch weight entries: \(error)")
            return []
        }
    }
    
    /// Apply raw HealthKit samples (e.g., from an anchored query) by collapsing them to the latest per day.
    /// Does NOT write back to HealthKit.
    func applyHealthKitSamples(_ samples: [HKQuantitySample]) {
        var latestByDay: [Date: (date: Date, kg: Double)] = [:]
        for s in samples {
            let day = calendar.startOfDay(for: s.endDate)
            let kg = s.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            if let current = latestByDay[day] {
                if s.endDate > current.date { latestByDay[day] = (s.endDate, kg) }
            } else {
                latestByDay[day] = (s.endDate, kg)
            }
        }
        guard let minDay = latestByDay.keys.min(), let maxDay = latestByDay.keys.max() else { return }
        let existing = fetchWeightsDict(from: minDay, to: maxDay)
        for (day, pair) in latestByDay {
            if existing[day] != pair.kg {
                saveWeight(for: day, weight: pair.kg, writeToHealthKit: false)
            }
        }
    }

    /// Optional windowed refresh using daily stats; useful before anchored queries are wired.
    func refreshFromHealthKitWindow(days: Int = 7, completion: (() -> Void)? = nil) {
        let end = Date()
        guard let start = calendar.date(byAdding: .day, value: -days, to: end) else { completion?(); return }
        let wm = WeightManager()
        wm.fetchLatestWeight { [weak self] latest in
            if let latest { self?.saveWeight(for: Date(), weight: latest.weight, writeToHealthKit: false) }
            wm.fetchHistoricalDailyWeights(startDate: start, endDate: end) { [weak self] daily in
                self?.importHistoricalWeights(daily)
                completion?()
            }
        }
    }

    // MARK: - Fetch helpers
    private func fetchEntries(from start: Date, to end: Date) -> [WeightEntry] {
        let fr: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fr.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do { return try context.fetch(fr) } catch { print("Fetch error: \(error)"); return [] }
    }

    private func fetchWeightsDict(from start: Date, to end: Date) -> [Date: Double] {
        var dict: [Date: Double] = [:]
        for e in fetchEntries(from: start, to: end) {
            if let d = e.date { dict[d] = e.weight }
        }
        return dict
    }
    
    // MARK: - Update Weight Data from HealthKit
    
    /// Updates weight data by fetching the latest value and historical data from HealthKit,
    /// then saving it into Core Data.
    func weightupdate() {
        let weightManager = WeightManager()
        
        // Fetch the latest weight and update today's entry.
        weightManager.fetchLatestWeight { [weak self] result in
            guard let self = self, let latestData = result else { return }
            DispatchQueue.main.async {
                self.saveWeight(for: Date(), weight: latestData.weight, writeToHealthKit: false)
            }
        }

        // Define the date range for historical data (for example, the last 7 days).
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        // Fetch historical daily weights from HealthKit and import them.
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { [weak self] historicalWeights in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.importHistoricalWeights(historicalWeights)
            }
        }
    }
    
    /// Upserts a WeightEntry in Core Data for a given day.
    private func upsertCoreDataWeight(on day: Date, weight: Double) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.fetch(fetchRequest)
            let entry = results.first ?? WeightEntry(context: context)
            entry.date = start
            entry.weight = weight

            // Ensure local changes trump any external ones
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()

            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            print("Failed to upsert WeightEntry: \(error)")
        }
    }
}

import Foundation
import CoreData
import Combine

// This manager handles saving, fetching, and updating weight history data using Core Data.
// It also imports historical weight data from HealthKit, making it available for your app.
class WeightHistoryManager: ObservableObject {
    // Shared instance to access the manager from anywhere in the app.
    static let shared = WeightHistoryManager()
    
    // The managed object context used for Core Data operations.
    private let context: NSManagedObjectContext
    
    // Initialize the manager, defaulting to the shared PersistenceController's view context.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Save or Update Weight Entry
    
    /// Saves or updates a weight entry for a specific date.
    /// - Parameters:
    ///   - date: The date for which the weight is recorded.
    ///   - weight: The weight value to save.
    func saveWeight(for date: Date, weight: Double) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        // 1) Write to HealthKit
        WeightManager().saveWeightSample(weight, date: startOfDay) { success, error in
            if let error = error {
                print("HealthKit save error: \(error)")
            }
            // 2) Upsert Core Data
            self.upsertCoreDataWeight(on: startOfDay, weight: weight)
        }
    }
    
    // MARK: - Import Historical Weights
    
    /// Imports historical weight data from HealthKit.
    /// - Parameter weights: An array of tuples, each containing a date string and a weight value.
    func importHistoricalWeights(_ weights: [(date: String, weight: Double)]) {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"

      for entry in weights {
        guard let date = formatter.date(from: entry.date) else { continue }

        // See if we already have a record for that exact day
        let existing = WeightHistoryManager.shared
                          .weightForPeriod(days: 365)
                          .first { $0.date == entry.date }

        // Only write if it’s missing or the value changed
        if existing == nil || existing!.weight != entry.weight {
          saveWeight(for: date, weight: entry.weight)
        }
      }
    }
    
    // MARK: - Fetch Weight Entries
    
    /// Fetches weight entries for the past `days` days.
    /// - Parameter days: The number of days to include.
    /// - Returns: An array of tuples, each containing a date string and the weight recorded for that day.
    func weightForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let calendar = Calendar.current
        // Calculate the start date for the period.
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) else { return [] }
        
        // Create a fetch request for WeightEntry objects starting from the calculated start date.
        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            // Try to fetch the results from Core Data.
            let results = try context.fetch(fetchRequest)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            // Map the results to an array of tuples with formatted dates and weights.
            return results.map { (date: formatter.string(from: $0.date ?? Date()), weight: $0.weight) }
        } catch {
            // Print an error message if the fetch fails.
            print("Failed to fetch weight entries: \(error)")
            return []
        }
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
                self.saveWeight(for: Date(), weight: latestData.weight)
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

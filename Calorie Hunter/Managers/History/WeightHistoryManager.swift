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
        // Get the start of the day for the given date.
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        // Calculate the end of the day by adding one day to the start.
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        // Set up a fetch request to see if there's already an entry for this day.
        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            // Try to fetch any existing weight entries for that day.
            let results = try context.fetch(fetchRequest)
            if let entry = results.first {
                // If an entry exists, update its weight.
                entry.weight = weight
            } else {
                // Otherwise, create a new weight entry.
                let newEntry = WeightEntry(context: context)
                newEntry.date = startOfDay
                newEntry.weight = weight
            }
            // Save changes to Core Data.
            try context.save()
            
            // Notify any observers (like SwiftUI views) about the change.
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            // Print an error message if something goes wrong.
            print("Failed to save weight: \(error)")
        }
    }
    
    // MARK: - Import Historical Weights
    
    /// Imports historical weight data from HealthKit.
    /// - Parameter weights: An array of tuples, each containing a date string and a weight value.
    func importHistoricalWeights(_ weights: [(date: String, weight: Double)]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Loop through each weight entry.
        for entry in weights {
            // Convert the date string to a Date object.
            if let date = formatter.date(from: entry.date) {
                // Save the weight for that date.
                self.saveWeight(for: date, weight: entry.weight)
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
}

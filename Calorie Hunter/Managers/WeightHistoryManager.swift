import Foundation
import CoreData
import Combine

class WeightHistoryManager: ObservableObject {
    static let shared = WeightHistoryManager()
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // Save or update a weight entry for a specific date.
    func saveWeight(for date: Date, weight: Double) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entry = results.first {
                entry.weight = weight
            } else {
                let newEntry = WeightEntry(context: context)
                newEntry.date = startOfDay
                newEntry.weight = weight
            }
            try context.save()
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            print("Failed to save weight: \(error)")
        }
    }
    
    // Import historical weights from HealthKit.
    func importHistoricalWeights(_ weights: [(date: String, weight: Double)]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for entry in weights {
            if let date = formatter.date(from: entry.date) {
                self.saveWeight(for: date, weight: entry.weight)
            }
        }
    }
    
    // Fetch weight entries for the past `days` days.
    func weightForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) else { return [] }
        
        let fetchRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return results.map { (date: formatter.string(from: $0.date ?? Date()), weight: $0.weight) }
        } catch {
            print("Failed to fetch weight entries: \(error)")
            return []
        }
    }
    
    // Update weight data by fetching from HealthKit and saving into Core Data.
    func weightupdate() {
        let weightManager = WeightManager()
        
        // Fetch the latest weight and update today's entry.
        weightManager.fetchLatestWeight { [weak self] latestWeight in
            guard let self = self, let weight = latestWeight else { return }
            DispatchQueue.main.async {
                self.saveWeight(for: Date(), weight: weight)
            }
        }
        
        // Define the range for historical data (e.g., last 7 days).
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { [weak self] historicalWeights in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.importHistoricalWeights(historicalWeights)
            }
        }
    }
}

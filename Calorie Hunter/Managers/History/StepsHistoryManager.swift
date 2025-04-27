import Foundation
import Combine
import CoreData

// This manager handles the storage and retrieval of daily steps history.
// It uses the ObservableObject protocol to notify any views when the data changes.
class StepsHistoryManager: ObservableObject {
    // Shared instance to allow easy access from anywhere in the app.
    static let shared = StepsHistoryManager()
    
    // The Core Data context for fetching and saving steps entries.
    private let viewContext = PersistenceController.shared.container.viewContext

    /// Imports the fetched steps data into Core Data.
    /// - Parameter stepsData: An array of tuples where each tuple contains a date string and the steps count.
    func importHistoricalSteps(_ stepsData: [(date: String, steps: Int)]) {
        viewContext.perform {
            for entry in stepsData {
                let fetchRequest: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateString == %@", entry.date)
                do {
                    let results = try self.viewContext.fetch(fetchRequest)
                    let obj = results.first ?? StepsEntry(context: self.viewContext)
                    obj.dateString = entry.date
                    obj.steps = Int64(entry.steps)
                } catch {
                    // Handle error if needed
                }
            }
            self.saveContext()
        }
    }
    
    /// Returns the step counts for the last given number of days.
    /// - Parameter days: The number of days to retrieve.
    /// - Returns: An array of tuples (date, steps) in chronological order.
    func stepsForPeriod(days: Int) -> [(date: String, steps: Int)] {
        var results: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                let fetchRequest: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString)
                do {
                    let entry = try viewContext.fetch(fetchRequest).first
                    let steps = entry?.steps ?? 0
                    results.append((dateString, Int(steps)))
                } catch {
                    results.append((dateString, 0))
                }
            }
        }
        return results.reversed()
    }
    
    /// Clears all locally stored steps data from Core Data.
    func clearData() {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StepsEntry.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.viewContext.execute(deleteRequest)
                self.saveContext()
            } catch {
                // Handle error if needed
            }
        }
    }
    
    /// Helper method to save the Core Data context.
    private func saveContext() {
        do {
            try viewContext.save()
            DispatchQueue.main.async { self.objectWillChange.send() }
        } catch {
            // Handle error if needed
        }
    }
}

import Foundation
import CoreData
import Combine

// ViewModel responsible for managing and updating water intake data using Core Data.
// It conforms to ObservableObject to enable SwiftUI views to automatically update when changes occur.
class WaterViewModel: ObservableObject {
    // Core Data container to manage the persistence layer.
    private let container: NSPersistentContainer
    // Published array of DailyWaterIntakeEntity objects that represents water intake records.
    @Published var dailyIntakes: [DailyWaterIntakeEntity] = []
    
    // Initializer that accepts a Core Data container and triggers an initial fetch of data.
    init(container: NSPersistentContainer) {
        self.container = container
        fetchDailyIntakes()
    }
    
    // MARK: - Data Fetching
    
    // Fetches all DailyWaterIntakeEntity records from the Core Data store.
    // The results are assigned to the published dailyIntakes property on the main thread to update the UI.
    func fetchDailyIntakes() {
        let request: NSFetchRequest<DailyWaterIntakeEntity> = DailyWaterIntakeEntity.fetchRequest()
        do {
            let entries = try container.viewContext.fetch(request)
            // Ensure that UI updates occur on the main thread.
            DispatchQueue.main.async {
                self.dailyIntakes = entries
            }
        } catch {
            print("Error fetching daily intakes: \(error)")
        }
    }
    
    // MARK: - Data Access and Update Methods
    
    // Returns the water amount recorded for a specific date.
    // It searches the dailyIntakes array for a matching entry based on the date.
    func waterAmount(for date: Date) -> Double {
        if let entry = dailyIntakes.first(where: {
            guard let entryDate = $0.date else { return false }
            // Compare using Calendar API to determine if the dates fall on the same day.
            return Calendar.current.isDate(entryDate, inSameDayAs: date)
        }) {
            return entry.waterAmount
        }
        // If no record is found for the specified date, return 0.0.
        return 0.0
    }
    
    // Sets the water amount for a specific date. It either updates an existing entry or creates a new one.
    func setWaterAmount(to newAmount: Double, for date: Date) {
        let calendar = Calendar.current
        // Define the start of the day.
        let startOfDay = calendar.startOfDay(for: date)
        // Calculate the end of the day by adding one day to the start.
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        let request: NSFetchRequest<DailyWaterIntakeEntity> = DailyWaterIntakeEntity.fetchRequest()
        // Predicate to fetch records for the specific day.
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        // Perform the context operations asynchronously.
        container.viewContext.perform {
            do {
                let results = try self.container.viewContext.fetch(request)
                let entry: DailyWaterIntakeEntity
                // If an entry already exists for the day, update it; otherwise, create a new one.
                if let existing = results.first {
                    entry = existing
                } else {
                    entry = DailyWaterIntakeEntity(context: self.container.viewContext)
                    entry.date = startOfDay
                    entry.waterAmount = 0
                }
                // Set the new water amount.
                entry.waterAmount = newAmount
                try self.container.viewContext.save()
                // After saving, refresh the dailyIntakes to reflect the changes in the UI.
                DispatchQueue.main.async {
                    self.fetchDailyIntakes()
                }
            } catch {
                print("Error setting water intake: \(error)")
            }
        }
    }
    
    // Adjusts the water amount for a specific date by a given delta value.
    // It fetches the record, updates it if it exists or creates a new one, then saves the context.
    func adjustWaterAmount(by delta: Double, for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let request: NSFetchRequest<DailyWaterIntakeEntity> = DailyWaterIntakeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        container.viewContext.perform {
            do {
                let results = try self.container.viewContext.fetch(request)
                let entry: DailyWaterIntakeEntity
                if let existing = results.first {
                    entry = existing
                    print("Existing entry found. Current water: \(entry.waterAmount)")
                } else {
                    entry = DailyWaterIntakeEntity(context: self.container.viewContext)
                    entry.date = startOfDay
                    entry.waterAmount = 0
                    print("No entry found. Creating new entry.")
                }
                // Apply the adjustment by the delta amount.
                entry.waterAmount += delta
                print("After delta: \(entry.waterAmount)")
                
                try self.container.viewContext.save()
                DispatchQueue.main.async {
                    self.fetchDailyIntakes()
                    print("Saved water intake: \(self.waterAmount(for: date))")
                }
            } catch {
                print("Error updating water intake: \(error)")
            }
        }
    }
    
    // MARK: - Data Preparation for Charts
    
    // Provides an array of tuples containing formatted date strings and corresponding water intake values
    // for the past 'days' days. This is useful for generating charts or graphs.
    func waterIntakesForPeriod(days: Int) -> [(date: String, water: Double)] {
        var data: [(date: String, water: Double)] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Loop backwards for the given number of days.
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let formattedDate = dateFormatter.string(from: date)
                let amount = waterAmount(for: date)
                data.append((date: formattedDate, water: amount))
            }
        }
        // Reverse the data so it is in chronological order.
        return data.reversed()
    }
}

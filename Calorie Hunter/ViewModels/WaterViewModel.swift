import Foundation
import CoreData
import Combine

class WaterViewModel: ObservableObject {
    private let container: NSPersistentContainer
    @Published var dailyIntakes: [DailyWaterIntakeEntity] = []
    
    init(container: NSPersistentContainer) {
        self.container = container
        fetchDailyIntakes()
    }
    
    func fetchDailyIntakes() {
        let request: NSFetchRequest<DailyWaterIntakeEntity> = DailyWaterIntakeEntity.fetchRequest()
        do {
            let entries = try container.viewContext.fetch(request)
            // Ensure UI updates on the main thread.
            DispatchQueue.main.async {
                self.dailyIntakes = entries
            }
        } catch {
            print("Error fetching daily intakes: \(error)")
        }
    }
    
    func waterAmount(for date: Date) -> Double {
        if let entry = dailyIntakes.first(where: {
            guard let entryDate = $0.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: date)
        }) {
            return entry.waterAmount
        }
        return 0.0
    }
    
    func setWaterAmount(to newAmount: Double, for date: Date) {
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
                } else {
                    entry = DailyWaterIntakeEntity(context: self.container.viewContext)
                    entry.date = startOfDay
                    entry.waterAmount = 0
                }
                entry.waterAmount = newAmount
                try self.container.viewContext.save()
                DispatchQueue.main.async {
                    self.fetchDailyIntakes()
                }
            } catch {
                print("Error setting water intake: \(error)")
            }
        }
    }
    
    func adjustWaterAmount(by delta: Double, for date: Date) {
        // Create start and end dates for today.
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
                    // Set the entry's date to a consistent value like startOfDay.
                    entry.date = startOfDay
                    entry.waterAmount = 0
                    print("No entry found. Creating new entry.")
                }
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



}

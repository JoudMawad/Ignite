import Foundation
import CoreData

class CalorieHistoryManager {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func totalCaloriesForDate(_ date: Date) -> Int {
        let dateString = formatDate(date)
        let fetchRequest: NSFetchRequest<CalorieEntry> = CalorieEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString)
        do {
            let results = try context.fetch(fetchRequest)
            return Int(results.first?.calories ?? 0)
        } catch {
            print("Error fetching calorie entry: \(error)")
            return 0
        }
    }
    
    /// Sum up every consumption entry ever saved.
    func totalLifetimeCalories() -> Int {
      let req: NSFetchRequest<ConsumptionEntity> = ConsumptionEntity.fetchRequest()
      do {
        let entries = try context.fetch(req)
        return entries.reduce(0) { sum, entry in
          guard let per100kcal = entry.food?.calories else { return sum }
          // Calculate calories based on gramsConsumed
          let kcal = Int(per100kcal * (entry.gramsConsumed / 100.0))
          return sum + kcal
        }
      } catch {
        print("Error fetching lifetime consumption:", error)
        return 0
      }
    }

    func totalCaloriesForPeriod(days: Int) -> [(date: String, calories: Int)] {
        var result: [(String, Int)] = []
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                let fetchRequest: NSFetchRequest<CalorieEntry> = CalorieEntry.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString)
                do {
                    let results = try context.fetch(fetchRequest)
                    let kcal = Int(results.first?.calories ?? 0)
                    result.append((dateString, kcal))
                } catch {
                    result.append((dateString, 0))
                }
            }
        }
        return result.reversed()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

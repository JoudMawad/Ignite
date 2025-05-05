import Foundation
import CoreData
import Combine

final class NutritionHistoryManager: ObservableObject {
    static let shared = NutritionHistoryManager()

    private let viewContext = PersistenceController.shared.container.viewContext

    /// Import or update daily nutrition entries for each date.
    func importHistoricalNutrition(
        _ data: [(date: String, calories: Double, protein: Double, carbs: Double, fat: Double)]
    ) {
        viewContext.perform {
            for entry in data {
                let req: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
                req.predicate = NSPredicate(format: "dateString == %@", entry.date)

                let object = (try? self.viewContext.fetch(req))?.first
                            ?? NutritionEntry(context: self.viewContext)

                object.dateString = entry.date
                object.calories   = entry.calories
                object.protein    = entry.protein
                object.carbs      = entry.carbs
                object.fat        = entry.fat
            }
            self.saveContext()
        }
    }

    /// Returns nutrition totals for the last `days` days, in chronological order.
    func nutritionForPeriod(days: Int)
      -> [(date: String, calories: Double, protein: Double, carbs: Double, fat: Double)]
    {
        var results: [(String, Double, Double, Double, Double)] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone   = .current

        for i in (0..<days).reversed() {
            let date = Calendar.current.date(
              byAdding: .day, value: -i, to: Date())!
            let ds = fmt.string(from: date)

            let req: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
            req.predicate = NSPredicate(format: "dateString == %@", ds)

            let entry = (try? viewContext.fetch(req))?.first

            results.append((
              ds,
              entry?.calories ?? 0,
              entry?.protein  ?? 0,
              entry?.carbs    ?? 0,
              entry?.fat      ?? 0
            ))
        }
        return results
    }

    // MARK: - Helpers

    private func saveContext() {
        do {
            try viewContext.save()
            DispatchQueue.main.async { self.objectWillChange.send() }
        } catch {
            print("Failed to save nutrition history:", error)
        }
    }
}

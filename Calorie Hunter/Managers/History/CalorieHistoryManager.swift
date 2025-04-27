import Foundation
import CoreData

class CalorieHistoryManager {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func checkForMidnightReset(foodItems: [FoodItem]) {
        saveDailyCalories(foodItems: foodItems)
    }

    private func saveDailyCalories(foodItems: [FoodItem]) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayFoods = foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: yesterday) }
        let yesterdayCalories = yesterdayFoods.reduce(0) { $0 + $1.calories }
        let dateString = formatDate(yesterday)

        let fetchRequest: NSFetchRequest<CalorieEntry> = CalorieEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString)
        do {
            let results = try context.fetch(fetchRequest)
            let entry = results.first ?? CalorieEntry(context: context)
            entry.dateString = dateString
            entry.calories = Int32(yesterdayCalories)
            try context.save()
            print("Saved \(yesterdayCalories) kcal for \(dateString)")
        } catch {
            print("Error saving calorie entry: \(error)")
        }
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

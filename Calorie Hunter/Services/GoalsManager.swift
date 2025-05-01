import Foundation
import CoreData
import Combine

/// Provides access to daily goals (steps, calories, water, …) stored in Core Data.
/// Persists changes immediately and can backfill missing days on demand.
final class GoalsManager: ObservableObject {
    static let shared = GoalsManager()
    
    private let container: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    
    @Published private(set) var cache: [String: DailyGoal] = [:]
    
    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.viewContext = container.viewContext
        loadTodayGoals()
        backfillMissingGoals(for: 30)
    }
    
    /// Fetch or create a goal record for a given type & date.
    func goalValue(for type: GoalType, on date: Date) -> Double {
        let key = cacheKey(type: type, date: date)
        if let goal = cache[key] { return goal.value }
        
        let request: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        request.predicate = NSPredicate(
            format: "dateString == %@ AND goalType == %@",
            DateFormatter.isoDate.string(from: date),
            type.rawValue
        )
        if let existing = (try? viewContext.fetch(request))?.first {
            cache[key] = existing
            return existing.value
        }
        
        // Create with fallback default
        let newGoal = DailyGoal(context: viewContext)
        newGoal.dateString = DateFormatter.isoDate.string(from: date)
        newGoal.goalType   = type.rawValue
        newGoal.value      = fallbackDefault(for: type)
        
        do {
            try viewContext.save()
            cache[key] = newGoal
        } catch {
            print("Error creating goal: \(error)")
        }
        return newGoal.value
    }
    
    /// Update or insert a goal record for a given type & date.
    func updateGoal(_ newValue: Double, for type: GoalType, on date: Date) {
        let key = cacheKey(type: type, date: date)
        let goal: DailyGoal
        if let existing = cache[key] {
            goal = existing
        } else {
            goal = DailyGoal(context: viewContext)
            goal.dateString = DateFormatter.isoDate.string(from: date)
            goal.goalType   = type.rawValue
        }
        goal.value = newValue
        do {
            try viewContext.save()
            cache[key] = goal
        } catch {
            print("Error updating goal: \(error)")
        }
    }
    
    /// Ensures each of the past `days` days has at least one goal entry.
    func backfillMissingGoals(for days: Int) {
        let calendar = Calendar.current
        let types: [GoalType] = GoalType.allCases
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dateString = DateFormatter.isoDate.string(from: date)
            
            for type in types {
                let fetch: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
                fetch.predicate = NSPredicate(
                    format: "dateString == %@ AND goalType == %@",
                    dateString, type.rawValue
                )
                let count = (try? viewContext.count(for: fetch)) ?? 0
                if count > 0 { continue }
                
                let entry = DailyGoal(context: viewContext)
                entry.dateString = dateString
                entry.goalType   = type.rawValue
                entry.value      = fallbackDefault(for: type)
            }
        }
        do {
            try viewContext.save()
        } catch {
            print("Error backfilling goals: \(error)")
        }
    }
    
    // MARK: - Helpers
    private func cacheKey(type: GoalType, date: Date) -> String {
        "\(type.rawValue)-\(DateFormatter.isoDate.string(from: date))"
    }
    
    private func fallbackDefault(for type: GoalType) -> Double {
        switch type {
        case .steps:        return 10_000
        case .calories:     return 2_000
        case .water:        return 3.0
        case .burnedCalories: return 500
        case .weight: return 70.0
        }
    }
    
    /// Pre-load today's goals into cache so that observers fire on launch.
    private func loadTodayGoals() {
        let today = Date()
        GoalType.allCases.forEach { _ = goalValue(for: $0, on: today) }
    }
}

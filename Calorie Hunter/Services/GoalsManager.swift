import Foundation
import CoreData
import Combine

/// Provides access to daily goals (steps, calories, water, …) stored in Core Data.
/// Persists changes immediately and can backfill missing days on demand.
final class GoalsManager: ObservableObject {
    static let shared = GoalsManager()

    private let container: NSPersistentContainer
    private let viewContext: NSManagedObjectContext

    // Keep cache internal and non-published to avoid unnecessary SwiftUI re-renders
    private var cache: [String: DailyGoal] = [:]

    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.viewContext = container.viewContext
        loadTodayGoals()
        // Run backfill off the main thread to avoid launch spikes
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.backfillMissingGoals(for: 30)
        }
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
            cache[key] = goal
        }
        goal.value = newValue
        do {
            try viewContext.save()
        } catch {
            print("Error updating goal: \(error)")
        }
    }

    /// Ensures each of the past `days` days has at least one goal entry.
    /// Runs on a background context and batches work to minimize SQLite hits.
    func backfillMissingGoals(for days: Int) {
        let bg = container.newBackgroundContext()
        bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        bg.perform {
            let calendar = Calendar.current
            var dateStrings: [String] = []
            dateStrings.reserveCapacity(days)
            for offset in 0..<days {
                if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                    dateStrings.append(DateFormatter.isoDate.string(from: date))
                }
            }

            let typeRawValues = GoalType.allCases.map { $0.rawValue }

            // Fetch all existing rows in one query
            let fetch: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
            fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "dateString IN %@", dateStrings),
                NSPredicate(format: "goalType IN %@", typeRawValues)
            ])

            let existing = (try? bg.fetch(fetch)) ?? []
            let existingKeys = Set(existing.compactMap { (g: DailyGoal) -> String? in
                guard let ds = g.dateString, let gt = g.goalType else { return nil }
                return "\(gt)-\(ds)"
            })

            // Create only the missing combinations
            for ds in dateStrings {
                for t in GoalType.allCases {
                    let key = "\(t.rawValue)-\(ds)"
                    if existingKeys.contains(key) { continue }
                    let entry = DailyGoal(context: bg)
                    entry.dateString = ds
                    entry.goalType   = t.rawValue
                    entry.value      = self.fallbackDefault(for: t)
                }
            }

            do { try bg.save() } catch {
                print("Error backfilling goals: \(error)")
            }
        }
    }

    // MARK: - Helpers
    private func cacheKey(type: GoalType, date: Date) -> String {
        "\(type.rawValue)-\(DateFormatter.isoDate.string(from: date))"
    }

    private func fallbackDefault(for type: GoalType) -> Double {
        switch type {
        case .steps:          return 10_000
        case .calories:       return 2_000
        case .water:          return 3.0
        case .burnedCalories: return 500
        case .weight:         return 70.0
        }
    }

    /// Pre-load today's goals into cache so that first reads are fast.
    private func loadTodayGoals() {
        let today = Date()
        GoalType.allCases.forEach { _ = goalValue(for: $0, on: today) }
    }
}

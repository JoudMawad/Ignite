import Foundation
import CoreData
import HealthKit  // if you plan to import HK data here, too

final class ExerciseHistoryManager {
    static let shared = ExerciseHistoryManager()
    private let context = PersistenceController.shared.container.viewContext

    private init() { }

    /// Saves or updates a single Exercise into Core Data.
    func save(_ exercise: Exercise) {

        // Check if an entity with this id already exists
        let request: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", exercise.id as CVarArg)
        if let results = try? context.fetch(request), let existing = results.first {
            // Update existing record
            existing.type = exercise.type
            existing.startDate = exercise.startDate
            existing.duration = exercise.duration
            existing.calories = exercise.calories
        } else {
            // Insert new record
            let entity = ExerciseEntity(context: context)
            entity.id = exercise.id
            entity.type = exercise.type
            entity.startDate = exercise.startDate
            entity.duration = exercise.duration
            entity.calories = exercise.calories
        }
        saveContext()

    }

    /// Fetches all exercises between two dates, sorted by startDate.
    func fetch(from start: Date, to end: Date) -> [Exercise] {
        let req: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        req.predicate = NSPredicate(format: "startDate >= %@ AND startDate <= %@", start as NSDate, end as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        let results = (try? context.fetch(req)) ?? []
        return results.map { e in
            Exercise(id: e.id!,
                     type: e.type ?? "",
                     startDate: e.startDate ?? Date(),
                     duration: e.duration,
                     calories: e.calories)
        }
    }

    /// Deletes the specified exercise from Core Data.
    /// - Parameter exercise: The Exercise model to remove.
    func delete(_ exercise: Exercise) {
        let request: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", exercise.id as CVarArg)
        if let results = try? context.fetch(request) {
            for object in results {
                context.delete(object)
            }
            saveContext()
        }
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do { try context.save() }
        catch { print("Failed to save ExerciseEntity:", error) }
    }
}

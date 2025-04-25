import Foundation
import Combine
import HealthKit

final class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var errorMessage: String?

    private let exerciseManager = ExerciseManager()
    private let historyManager = ExerciseHistoryManager.shared

    /// Load all exercises between the given dates (e.g. start-of-day → now).
    func loadExercises(from start: Date, to end: Date) {
        exerciseManager.fetchExercises(start: start, end: end) { hkExercises in
            DispatchQueue.main.async {
                if hkExercises.isEmpty {
                    // HealthKit unavailable or no workouts: use local history
                    self.exercises = self.historyManager.fetch(from: start, to: end)
                } else {
                    // Save or update imported workouts to Core Data
                    hkExercises.forEach { self.historyManager.save($0) }
                    // Display HealthKit workouts only (avoid duplicates)
                    self.exercises = hkExercises.sorted { $0.startDate < $1.startDate }
                }
            }
        }
    }

    /// Deletes an exercise from HealthKit and local storage, and updates the list.
    func deleteExercise(_ exercise: Exercise) {
        exerciseManager.deleteExercise(exercise) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Update in-memory list
                    if let idx = self.exercises.firstIndex(where: { $0.id == exercise.id }) {
                        self.exercises.remove(at: idx)
                        // Reload today's exercises to reflect deletion immediately
                        let startOfDay = Calendar.current.startOfDay(for: Date())
                        self.loadExercises(from: startOfDay, to: Date())
                    }
                } else {
                    // Handle deletion error
                    self.errorMessage = error?.localizedDescription ?? "Failed to delete exercise."
                }
            }
        }
    }

    /// Save a new manual exercise (will write to HK + CoreData).
    func addExercise(type: HKWorkoutActivityType,
                     startDate: Date,
                     duration: TimeInterval,
                     calories: Double) {
        exerciseManager.saveExercise(type: type,
                                     startDate: startDate,
                                     duration: duration,
                                     calories: calories) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Reload today's exercises (including this one) so displayName mapping is applied
                    let startOfDay = Calendar.current.startOfDay(for: startDate)
                    self.loadExercises(from: startOfDay, to: Date())
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to save exercise."
                }
            }
        }
    }
}

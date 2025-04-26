import Foundation
import Combine
import HealthKit
import SwiftUI

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

    // MARK: - Calorie Estimation

    /// Returns the MET value for a given activity type.
    private func metForActivityType(_ type: HKWorkoutActivityType) -> Double {
        switch type {
        case .running: return 9.8
        case .walking: return 3.8
        case .cycling: return 7.5
        case .swimming: return 5.8
        case .yoga: return 2.5
        case .traditionalStrengthTraining: return 6.0
        case .functionalStrengthTraining: return 6.0
        case .coreTraining: return 3.8
        case .elliptical: return 5.0
        case .rowing: return 7.0
        case .stairClimbing: return 8.8
        case .hiking: return 6.0
        case .dance: return 5.5
        case .cardioDance: return 5.5
        case .socialDance: return 5.5
        case .barre: return 3.0
        case .pilates: return 3.0
        case .highIntensityIntervalTraining: return 8.0
        case .mixedCardio: return 6.0
        case .wheelchairWalkPace: return 4.0
        case .wheelchairRunPace: return 6.0
        case .taiChi: return 3.0
        case .crossTraining: return 6.0
        case .snowSports: return 5.5
        case .skatingSports: return 7.0
        case .surfingSports: return 5.0
        case .mindAndBody: return 2.5
        case .flexibility: return 2.5
        case .climbing: return 8.0
        case .fishing: return 2.0
        case .golf: return 3.5
        case .martialArts: return 6.0
        case .boxing: return 7.0
        case .soccer: return 7.0
        case .basketball: return 6.5
        case .americanFootball: return 8.0
        case .baseball: return 5.0
        case .cricket: return 5.5
        case .lacrosse: return 7.0
        case .rugby: return 8.5
        case .softball: return 5.0
        case .tennis: return 7.3
        case .tableTennis: return 4.0
        case .volleyball: return 3.5
        case .handball: return 8.0
        case .badminton: return 5.5
        // Add more as needed, using reasonable defaults
        default: return 4.0 // fallback for any unlisted activity
        }
    }

    // MARK: - Distance-based Activities

    /// Activities where manual entry requires a distance value
    private let distanceBasedActivities: Set<HKWorkoutActivityType> = [
        .running,
        .walking,
        .cycling
    ]

    /// Save a new manual exercise by estimating calories from duration and the user's weight.
    func addExercise(
        type: HKWorkoutActivityType,
        startDate: Date,
        duration: TimeInterval,
        distance: Double? = nil,
        heartRate: Double? = nil,
        userProfile: UserProfileViewModel
    ) {
        let weightKg = userProfile.currentWeight
        let estimatedCalories: Double
        
        // 1. If heart rate data is provided, use HR-based formula
        if let hr = heartRate {
            let age = userProfile.age
            let durationMin = duration / 60.0
            if userProfile.gender.lowercased() == "male" {
                estimatedCalories = ((Double(age) * 0.2017) - (weightKg * 0.09036) + (hr * 0.6309) - 55.0969) * durationMin / 4.184
            } else {
                estimatedCalories = ((Double(age) * 0.074) - (weightKg * 0.05741) + (hr * 0.4472) - 20.4022) * durationMin / 4.184
            }
        }
        // 2. Else if distance-based activity
        else if distanceBasedActivities.contains(type) {
            guard let dist = distance else {
                DispatchQueue.main.async {
                    self.errorMessage = "Please enter a distance for \(type)"
                }
                return
            }
            let distKm = dist / 1000.0
            let factor: Double = {
                switch type {
                case .running: return 1.0
                case .walking: return 0.5
                case .cycling: return 0.3
                default: return 1.0
                }
            }()
            estimatedCalories = weightKg * distKm * factor
        }
        // 3. Fallback to MET-based estimation with gender & age adjustment
        else {
            let met = metForActivityType(type)
            let hours = duration / 3600.0
            let baseCalories = met * weightKg * hours
            // Gender adjustment (women ~5% lower)
            let genderFactor = (userProfile.gender == "female") ? 0.95 : 1.0
            // Age adjustment: –1% per decade over age 20
            let decadesOver20 = Double(max(0, userProfile.age - 20)) / 10.0
            let ageFactor = 1.0 - 0.01 * decadesOver20
            estimatedCalories = baseCalories * genderFactor * ageFactor
        }

        exerciseManager.saveExercise(
            type: type,
            startDate: startDate,
            duration: duration,
            calories: estimatedCalories
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    let startOfDay = Calendar.current.startOfDay(for: startDate)
                    self.loadExercises(from: startOfDay, to: Date())
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to save exercise."
                }
            }
        }
    }
}

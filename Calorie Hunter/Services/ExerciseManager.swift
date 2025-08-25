//
//  ExerciseManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 25.04.25.
//

import Foundation
import HealthKit

extension HKWorkoutActivityType {
    /// Human-readable display name for each workout activity type.
    var displayName: String {
        switch self {
        case .americanFootball:       return "Football"
        case .archery:                return "Archery"
        case .australianFootball:     return "Australian Football"
        case .badminton:              return "Badminton"
        case .baseball:               return "Baseball"
        case .basketball:             return "Basketball"
        case .bowling:                return "Bowling"
        case .boxing:                 return "Boxing"
        case .climbing:               return "Climbing"
        case .cricket:                return "Cricket"
        case .curling:                return "Curling"
        case .cycling:                return "Cycling"
        case .crossTraining:          return "Cross Training"
        case .dance:                  return "Dance"
        case .cardioDance:            return "Cardio Dance"
        case .socialDance:            return "Social Dance"
        case .barre:                  return "Barre"
        case .elliptical:             return "Elliptical"
        case .equestrianSports:       return "Equestrian"
        case .fencing:                return "Fencing"
        case .fishing:                return "Fishing"
        case .functionalStrengthTraining: return "Strength Training"
        case .golf:                   return "Golf"
        case .gymnastics:             return "Gymnastics"
        case .handball:               return "Handball"
        case .hiking:                 return "Hiking"
        case .hockey:                 return "Hockey"
        case .hunting:                return "Hunting"
        case .lacrosse:               return "Lacrosse"
        case .martialArts:            return "Martial Arts"
        case .mindAndBody:            return "Mind & Body"
        case .mixedCardio:                return "Mixed Cardio"
        case .paddleSports:           return "Paddle Sports"
        case .play:                   return "Play"
        case .preparationAndRecovery: return "Recovery"
        case .racquetball:            return "Racquetball"
        case .rowing:                 return "Rowing"
        case .rugby:                  return "Rugby"
        case .running:                return "Running"
        case .sailing:                return "Sailing"
        case .skatingSports:          return "Skating"
        case .snowSports:             return "Snow Sports"
        case .soccer:                 return "Soccer"
        case .softball:               return "Softball"
        case .squash:                 return "Squash"
        case .stairClimbing:          return "Stair Climbing"
        case .surfingSports:          return "Surfing"
        case .swimming:               return "Swimming"
        case .tableTennis:            return "Table Tennis"
        case .tennis:                 return "Tennis"
        case .trackAndField:          return "Track & Field"
        case .traditionalStrengthTraining: return "Strength Training"
        case .volleyball:             return "Volleyball"
        case .walking:                return "Walking"
        case .waterFitness:           return "Water Fitness"
        case .waterPolo:              return "Water Polo"
        case .waterSports:            return "Water Sports"
        case .wrestling:              return "Wrestling"
        case .yoga:                   return "Yoga"
        default:
            return String(describing: self).capitalized
        }
    }
}

final class ExerciseManager {
    private let healthKitManager = HealthKitManager()
    
    func startObservingWorkouts(onChange: @escaping () -> Void) {
        healthKitManager.startWorkoutObserver(onChange: onChange)
    }
    
    /// Fetches workouts from HealthKit within the given date range and maps them to Exercise models.
    func fetchExercises(start: Date, end: Date, completion: @escaping ([Exercise]) -> Void) {
        healthKitManager.fetchWorkouts(start: start, end: end) { workouts, error in
            guard let workouts = workouts, error == nil else {
                completion([])
                return
            }
            guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                completion([])
                return
            }
            let exercises = workouts.map { workout in
                let typeString = workout.workoutActivityType.displayName
                let duration = workout.duration
                let calories = workout.statistics(for: caloriesType)?
                                    .sumQuantity()?
                                    .doubleValue(for: HKUnit.kilocalorie()) ?? 0
                return Exercise(id: workout.uuid,
                                type: typeString,
                                startDate: workout.startDate,
                                duration: duration,
                                calories: calories)
            }
            completion(exercises)
        }
    }
    
    /// Saves a manual exercise entry into HealthKit.
    func saveExercise(type: HKWorkoutActivityType,
                      startDate: Date,
                      duration: TimeInterval,
                      calories: Double,
                      completion: @escaping (Bool, Error?) -> Void) {
        healthKitManager.saveWorkout(type: type,
                                     startDate: startDate,
                                     duration: duration,
                                     calories: calories) { success, error in
            completion(success, error)
        }
    }
    /// Deletes an exercise from HealthKit and Core Data in one call.
    /// - Parameters:
    ///   - exercise: The Exercise model to delete.
    ///   - completion: Called with success status and optional error.
    func deleteExercise(_ exercise: Exercise, completion: @escaping (Bool, Error?) -> Void) {
        // Delete corresponding workouts from HealthKit
        healthKitManager.deleteWorkouts(
            start: exercise.startDate,
            end: exercise.startDate.addingTimeInterval(exercise.duration)
        ) { success, error in
            if success {
                // Remove from Core Data
                ExerciseHistoryManager.shared.delete(exercise)
            }
            completion(success, error)
        }
    }
}

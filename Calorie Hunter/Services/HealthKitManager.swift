import HealthKit
import Foundation

// HealthKitManager is a singleton that handles all interactions with HealthKit.
// It manages requesting authorization and setting up background data delivery for key health metrics.
final class HealthKitManager {
    // Shared instance to ensure a single point of interaction with HealthKit throughout the app.
    static let shared = HealthKitManager()
    // HealthStore is the central object for HealthKit interactions.
    let healthStore = HKHealthStore()
    
    /// Requests authorization from the user to read key HealthKit data types.
    /// - Parameter completion: A closure that receives a success flag and an optional error.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Define the data types we want to read: body mass, step count, active energy burned, and dietary water.
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            // If any of the required types are not available, complete with false.
            completion(false, nil)
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        
        // Grant permission to write workouts, active energy, body mass (weight), and water
        let typesToShare: Set<HKSampleType> = [
            workoutType,
            activeEnergyType,
            bodyMassType,
            waterType
        ]
        let typesToRead: Set<HKObjectType> = [
            bodyMassType,
            stepType,
            activeEnergyType,
            workoutType,
            waterType
        ]
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    /// Enables background data delivery for all relevant health metrics.
    /// This ensures that updates for steps and active energy burned are delivered even when the app is in the background.
    func enableBackgroundDeliveryForAll() {
        // Enable background delivery for active energy burned data.
        enableBackgroundDelivery(for: .activeEnergyBurned)
        // Enable background delivery for step count data.
        enableBackgroundDelivery(for: .stepCount)
        // Enable background delivery for Water data.
        enableBackgroundDelivery(for: .dietaryWater)
    }
    
    /// Deletes all workout samples between two dates from HealthKit.
    func deleteWorkouts(start: Date, end: Date, completion: @escaping (Bool, Error?) -> Void) {
        // First delete the active‑energy samples written for those workouts
        deleteEnergySamples(start: start, end: end) { samplesOk, samplesErr in
            guard samplesOk else { completion(false, samplesErr); return }

            // Now fetch and delete workouts
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { _, samples, error in
                guard let workouts = samples as? [HKWorkout], error == nil else {
                    completion(false, error)
                    return
                }
                let group = DispatchGroup()
                var anyError: Error?
                var successAll = true
                for workout in workouts {
                    group.enter()
                    self.healthStore.delete(workout) { success, error in
                        if !success { successAll = false; anyError = error }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(successAll, anyError)
                }
            }
            self.healthStore.execute(query)
        }
    }

    /// Deletes all active-energy samples between two dates from HealthKit.
    func deleteEnergySamples(start: Date, end: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        healthStore.deleteObjects(of: energyType, predicate: predicate) { success, _, error in
            completion(success, error)
        }
    }
    
    /// Sets up background delivery for a specific HealthKit quantity type.
    /// - Parameter identifier: The HealthKit identifier for the quantity type (e.g., step count, active energy burned).
    private func enableBackgroundDelivery(for identifier: HKQuantityTypeIdentifier) {
        // Retrieve the corresponding quantity type from the identifier.
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            return
        }
        
        // Enable background delivery with immediate frequency.
        healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
            // The completion handler can be used for debugging or handling errors if needed.
            // In this example, no debug statements are included.
        }
    }
    
    /// Fetches workouts between two dates from HealthKit.
    func fetchWorkouts(start: Date, end: Date, completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sort]) { _, samples, error in
            completion(samples as? [HKWorkout], error)
        }
        healthStore.execute(query)
    }

    /// Saves a workout (including calories burned) to HealthKit.
    func saveWorkout(type: HKWorkoutActivityType,
                     startDate: Date,
                     duration: TimeInterval,
                     calories: Double,
                     completion: @escaping (Bool, Error?) -> Void) {
        let endDate = startDate.addingTimeInterval(duration)
        // Configure the workout
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        // Create the builder
        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: configuration,
                                       device: .local())
        // Begin collection
        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                completion(false, error)
                return
            }
            // End collection immediately since we don't stream live data
            builder.endCollection(withEnd: endDate) { success, error in
                guard success else {
                    completion(false, error)
                    return
                }
                // Create a single energy sample that represents the whole workout
                guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                    completion(false, nil)
                    return
                }
                let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
                let energySample = HKQuantitySample(type: energyType,
                                                    quantity: energyQuantity,
                                                    start: startDate,
                                                    end: endDate)

                // Add the energy sample to the builder
                builder.add([energySample]) { success, error in
                    guard success else {
                        completion(false, error)
                        return
                    }
                    // Finish the workout (no arguments) and return result
                    builder.finishWorkout { workout, error in
                        completion(workout != nil, error)
                    }
                }
            }
        }
    }
    /// Writes a water intake sample (in liters) to HealthKit, appending a new sample for each call.
    func saveWaterSample(_ liters: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, nil)
            return
        }
        let quantity = HKQuantity(unit: .liter(), doubleValue: liters)
        let sample = HKQuantitySample(type: waterType,
                                      quantity: quantity,
                                      start: date,
                                      end: date)
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    /// Fetches daily total water intake between two dates.
    func fetchDailyWater(startDate: Date, endDate: Date, completion: @escaping ([(date: String, amount: Double)]) -> Void) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: waterType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        query.initialResultsHandler = { _, results, _ in
            var data: [(String, Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                let amount = statistics.sumQuantity()?.doubleValue(for: .liter()) ?? 0
                data.append((dateStr, amount))
            }
            DispatchQueue.main.async { completion(data) }
        }
        healthStore.execute(query)
    }
}

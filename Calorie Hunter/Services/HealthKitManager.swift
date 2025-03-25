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
        // Define the data types we want to read: body mass, step count, and active energy burned.
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            // If any of the required types are not available, complete with false.
            completion(false, nil)
            return
        }
        
        // Create a set of types to read from HealthKit.
        let typesToRead: Set<HKObjectType> = [bodyMassType, stepType, activeEnergyType]
        // Request read-only permissions for these types.
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
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
}

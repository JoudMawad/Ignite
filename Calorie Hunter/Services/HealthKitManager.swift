import HealthKit
import Foundation

final class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [bodyMassType, stepType, activeEnergyType]
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func enableBackgroundDeliveryForAll() {
        enableBackgroundDelivery(for: .activeEnergyBurned)
        enableBackgroundDelivery(for: .stepCount)
    }
    
    private func enableBackgroundDelivery(for identifier: HKQuantityTypeIdentifier) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            print("DEBUG: Unable to create HKQuantityType for \(identifier)")
            return
        }
        
        healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
            if let error = error {
                print("Error enabling background delivery for \(identifier): \(error.localizedDescription)")
            } else {
                print("Background delivery for \(identifier) enabled successfully.")
            }
        }
    }
}

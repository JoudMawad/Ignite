import SwiftUI
import Combine
import HealthKit

class StepsViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let stepsManager = StepsManager()
    private var observerQuery: HKObserverQuery?
    
    @Published var currentSteps: Int = 0
    
    init() {
        // Load stored value or default to 0.
        self.currentSteps = UserDefaults.standard.integer(forKey: "steps")
        requestAuthorization()
        startObservingSteps()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalStepsFromHealthKit()
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func importHistoricalStepsFromHealthKit() {
        // Example: fetch the last year of data.
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        stepsManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            StepsHistoryManager.shared.importHistoricalSteps(stepsData)
            print("DEBUG: Imported historical steps from HealthKit into StepsHistoryManager.")
        }
    }
    
    private func updateSteps(with newValue: Int) {
        UserDefaults.standard.set(newValue, forKey: "steps")
        DispatchQueue.main.async {
            self.currentSteps = newValue
        }
    }
    
    private func startObservingSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            guard let self = self else { return }
            if let error = error {
                print("Error in steps observer query: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // Fetch the latest steps immediately with an anchored query:
            self.fetchLatestSteps { latestSteps in
                self.updateSteps(with: latestSteps)
                completionHandler()
            }
        }
        
        if let query = observerQuery {
            healthKitManager.healthStore.execute(query)
        }
    }

    private func fetchLatestSteps(completion: @escaping (Int) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let sampleQuery = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            let steps = samples.reduce(0) { sum, sample in
                sum + Int(sample.quantity.doubleValue(for: .count()))
            }
            completion(steps)
        }
        
        healthKitManager.healthStore.execute(sampleQuery)
    }

}

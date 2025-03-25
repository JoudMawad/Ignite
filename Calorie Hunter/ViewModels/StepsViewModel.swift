import SwiftUI
import Combine
import HealthKit

// StepsViewModel is responsible for fetching, observing, and updating the user's step count.
// It leverages HealthKit to fetch historical data and to observe real-time step changes.
class StepsViewModel: ObservableObject {
    // Reference to the shared HealthKitManager to handle HealthKit-related tasks.
    private let healthKitManager = HealthKitManager.shared
    // StepsManager is used to fetch historical steps data from HealthKit.
    private let stepsManager = StepsManager()
    // Optional observer query for monitoring step count changes in HealthKit.
    private var observerQuery: HKObserverQuery?
    
    // Published property for the current step count so that SwiftUI views can react to changes.
    @Published var currentSteps: Int = 0
    
    init() {
        // Load the stored step count value from UserDefaults or default to 0.
        self.currentSteps = UserDefaults.standard.integer(forKey: "steps")
        // Request HealthKit authorization to access step count data.
        requestAuthorization()
        // Start observing HealthKit for real-time updates on step count changes.
        startObservingSteps()
    }
    
    /// Requests HealthKit authorization to read step count data.
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                // If authorized, import historical steps data (e.g., for the past year).
                self.importHistoricalStepsFromHealthKit()
            } else {
                // Handle errors if needed.
            }
        }
    }
    
    /// Imports historical steps data from HealthKit.
    /// In this example, it fetches data from the past year.
    func importHistoricalStepsFromHealthKit() {
        // Calculate the date one year ago from today.
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        // Use the StepsManager to fetch daily step counts for the specified date range.
        stepsManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            // Import the fetched steps data into a shared history manager.
            StepsHistoryManager.shared.importHistoricalSteps(stepsData)
        }
    }
    
    /// Updates the stored step count and the published currentSteps property.
    /// - Parameter newValue: The latest step count value.
    private func updateSteps(with newValue: Int) {
        // Save the new step count to UserDefaults.
        UserDefaults.standard.set(newValue, forKey: "steps")
        // Update the published property on the main thread so that the UI reflects the new value.
        DispatchQueue.main.async {
            self.currentSteps = newValue
        }
    }
    
    /// Starts observing HealthKit for any changes in step count.
    /// This method sets up an observer query that triggers whenever new step data is available.
    private func startObservingSteps() {
        // Ensure the step count quantity type is available.
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        // Create an observer query for step count changes.
        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            guard let self = self else {
                completionHandler()
                return
            }
            if error != nil {
                // In case of error, complete the query and return.
                completionHandler()
                return
            }
            
            // Fetch the latest step count immediately using an anchored query.
            self.fetchLatestSteps { latestSteps in
                // Update the published step count and save the new value.
                self.updateSteps(with: latestSteps)
                // Call the completion handler to let HealthKit know the update is complete.
                completionHandler()
            }
        }
        
        // Execute the observer query if it was successfully created.
        if let query = observerQuery {
            healthKitManager.healthStore.execute(query)
        }
    }

    /// Fetches the latest steps for today using a sample query.
    /// - Parameter completion: A closure that returns the latest step count.
    private func fetchLatestSteps(completion: @escaping (Int) -> Void) {
        // Ensure the step count quantity type is available.
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        // Define the start of the day for the query.
        let startOfDay = Calendar.current.startOfDay(for: Date())
        // Create a predicate to fetch samples from the start of the day until now.
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        // Create a sample query to fetch all step samples for today.
        let sampleQuery = HKSampleQuery(sampleType: stepType,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: nil) { _, samples, error in
            // Ensure that the query returned valid samples without error.
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            // Sum the steps from all samples using the .count unit.
            let steps = samples.reduce(0) { sum, sample in
                sum + Int(sample.quantity.doubleValue(for: .count()))
            }
            completion(steps)
        }
        
        // Execute the sample query on the health store.
        healthKitManager.healthStore.execute(sampleQuery)
    }
}

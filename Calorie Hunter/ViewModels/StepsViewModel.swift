import SwiftUI
import Combine
import HealthKit
import CoreData

class StepsViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let stepsManager = StepsManager()
    private var observerQuery: HKObserverQuery?
    private let viewContext = PersistenceController.shared.container.viewContext

    // The latest steps for today, published for UI updates.
    @Published var currentSteps: Int = 0
    
    init() {
        // Load the stored step count value for today from Core Data, fallback to 0.
        self.currentSteps = fetchStepsFromCoreData(for: Date())
        // Request HealthKit authorization to access step count data.
        requestAuthorization()
        // Start observing HealthKit for real-time updates.
        startObservingSteps()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalStepsFromHealthKit()
            }
        }
    }
    
    func importHistoricalStepsFromHealthKit() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        stepsManager.fetchHistoricalDailySteps(startDate: startDate, endDate: endDate) { stepsData in
            StepsHistoryManager.shared.importHistoricalSteps(stepsData)
            // Update today's steps from the imported data if today is included
            if let todayEntry = stepsData.first(where: { $0.date == self.dateString(from: Date()) }) {
                self.updateSteps(with: todayEntry.steps)
            }
        }
    }
    
    private func updateSteps(with newValue: Int) {
        saveStepsToCoreData(for: Date(), steps: newValue)
        DispatchQueue.main.async {
            self.currentSteps = newValue
        }
    }
    
    private func startObservingSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            guard let self = self else { completionHandler(); return }
            if error != nil { completionHandler(); return }
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
    
    // MARK: - Core Data Helpers

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    private func fetchStepsFromCoreData(for date: Date) -> Int {
        let fetchRequest: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString(from: date))
        do {
            let entry = try viewContext.fetch(fetchRequest).first
            return Int(entry?.steps ?? 0)
        } catch {
            return 0
        }
    }

    private func saveStepsToCoreData(for date: Date, steps: Int) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "dateString == %@", self.dateString(from: date))
            do {
                let results = try self.viewContext.fetch(fetchRequest)
                let obj = results.first ?? StepsEntry(context: self.viewContext)
                obj.dateString = self.dateString(from: date)
                obj.steps = Int64(steps)
                try self.viewContext.save()
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } catch {
                // Handle save error if needed
            }
        }
    }
    
    func steps(for date: Date) -> Int {
          fetchStepsFromCoreData(for: date)
      }
}

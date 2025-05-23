import SwiftUI
import Combine
import HealthKit
import CoreData

class StepsViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let stepsManager = StepsManager()
    private var observerQuery: HKObserverQuery?
    /// Observer for live distance updates
    private var distanceObserverQuery: HKObserverQuery?
    private let viewContext = PersistenceController.shared.container.viewContext

    // MARK: - Published Properties

    /// The latest step count for today.
    @Published var currentSteps: Int = 0
    /// The latest walking/running distance (in meters) for today.
    @Published var currentDistance: Double = 0.0

    init() {
        // Load today’s saved values from Core Data
        self.currentSteps = fetchStepsFromCoreData(for: Date())
        self.currentDistance = fetchDistanceFromCoreData(for: Date())

        // Request HealthKit permissions and import historical data
        requestAuthorization()

        // Observe live updates to steps
        startObservingSteps()
        // Observe live distance updates
        startObservingDistance()
        // Optionally: set up periodic refresh for live distance if needed
    }

    // MARK: - Authorization & Initial Imports

    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            guard success else { return }
            // Import up to last year of data
            let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            let end   = Date()
            self.importHistoricalSteps(from: start, to: end)
            self.importHistoricalDistance(from: start, to: end)
        }
    }

    private func importHistoricalSteps(from start: Date, to end: Date) {
        stepsManager.fetchHistoricalDailySteps(startDate: start, endDate: end) { data in
            // Persist and update today’s value
            StepsHistoryManager.shared.importHistoricalSteps(data)
            if let today = data.first(where: { $0.date == self.dateString(from: Date()) }) {
                self.updateSteps(today.steps)
            }
        }
    }

    private func importHistoricalDistance(from start: Date, to end: Date) {
        stepsManager.fetchHistoricalWalkingDistance(startDate: start, endDate: end) { data in
            StepsHistoryManager.shared.importHistoricalDistances(data)
            if let today = data.first(where: { $0.date == self.dateString(from: Date()) }) {
                self.updateDistance(today.distanceInMeters)
            }
        }
    }

    // MARK: - Live Observing

    private func startObservingSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completion, error in
            guard let self = self, error == nil else { completion(); return }
            self.fetchLatestSteps { count in
                self.updateSteps(count)
                completion()
            }
        }
        if let query = observerQuery {
            healthKitManager.healthStore.execute(query)
        }
    }

    /// Begins observing HealthKit for live walking/running distance updates.
    private func startObservingDistance() {
        guard let distType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        distanceObserverQuery = HKObserverQuery(sampleType: distType, predicate: nil) { [weak self] _, completionHandler, error in
            guard let self = self, error == nil else { completionHandler(); return }
            self.fetchLatestDistance { meters in
                self.updateDistance(meters)
                completionHandler()
            }
        }
        if let query = distanceObserverQuery {
            healthKitManager.healthStore.execute(query)
        }
    }

    /// Fetches the total walking/running distance for today and returns it in meters.
    private func fetchLatestDistance(completion: @escaping (Double) -> Void) {
        guard let distType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKSampleQuery(sampleType: distType,
                                   predicate: predicate,
                                   limit: HKObjectQueryNoLimit,
                                   sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            let totalMeters = samples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: .meter())
            }
            completion(totalMeters)
        }
        healthKitManager.healthStore.execute(query)
    }

    private func fetchLatestSteps(completion: @escaping (Int) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate  = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKSampleQuery(sampleType: stepType,
                                   predicate: predicate,
                                   limit: HKObjectQueryNoLimit,
                                   sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(0)
                return
            }
            let total = samples.reduce(0) { $0 + Int($1.quantity.doubleValue(for: .count())) }
            completion(total)
        }
        healthKitManager.healthStore.execute(query)
    }

    // MARK: - Data Updates

    private func updateSteps(_ newValue: Int) {
        saveStepsToCoreData(for: Date(), steps: newValue)
        DispatchQueue.main.async { self.currentSteps = newValue }
    }

    private func updateDistance(_ newValue: Double) {
        saveDistanceToCoreData(for: Date(), distance: newValue)
        DispatchQueue.main.async { self.currentDistance = newValue }
    }

    // MARK: - Core Data Helpers

    private func dateString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone   = .current
        return fmt.string(from: date)
    }

    private func fetchStepsFromCoreData(for date: Date) -> Int {
        let req: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
        req.predicate = NSPredicate(format: "dateString == %@", dateString(from: date))
        return (try? viewContext.fetch(req).first?.steps).map(Int.init) ?? 0
    }

    private func saveStepsToCoreData(for date: Date, steps: Int) {
        viewContext.perform {
            let req: NSFetchRequest<StepsEntry> = StepsEntry.fetchRequest()
            req.predicate = NSPredicate(format: "dateString == %@", self.dateString(from: date))
            let obj = (try? self.viewContext.fetch(req).first) ?? StepsEntry(context: self.viewContext)
            obj.dateString = self.dateString(from: date)
            obj.steps      = Int64(steps)
            try? self.viewContext.save()
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    private func fetchDistanceFromCoreData(for date: Date) -> Double {
        let req: NSFetchRequest<DistanceEntry> = DistanceEntry.fetchRequest()
        req.predicate = NSPredicate(format: "dateString == %@", dateString(from: date))
        return (try? viewContext.fetch(req).first?.distance) ?? 0.0
    }

    private func saveDistanceToCoreData(for date: Date, distance: Double) {
        viewContext.perform {
            let req: NSFetchRequest<DistanceEntry> = DistanceEntry.fetchRequest()
            req.predicate = NSPredicate(format: "dateString == %@", self.dateString(from: date))
            let obj = (try? self.viewContext.fetch(req).first) ?? DistanceEntry(context: self.viewContext)
            obj.dateString = self.dateString(from: date)
            obj.distance   = distance
            try? self.viewContext.save()
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    // MARK: - Public Fetchers

    /// Returns steps for a specific date.
    func steps(for date: Date) -> Int {
        fetchStepsFromCoreData(for: date)
    }

    /// Returns distance for a specific date in meters.
    func distance(for date: Date) -> Double {
        fetchDistanceFromCoreData(for: date)
    }
}

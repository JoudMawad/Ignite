import HealthKit
import Foundation


extension Notification.Name {
    static let healthKitBurnedCaloriesDataChanged = Notification.Name("healthKitBurnedCaloriesDataChanged")
}

final class BurnedCaloriesManager {
    // MARK: - Singleton & Store
    static let shared = BurnedCaloriesManager()
    let healthStore = HKHealthStore()

    // MARK: - Internal State
    private var observerQuery: HKObserverQuery?
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var anchor: HKQueryAnchor?
    private var totalTodayKCal: Double = 0
    private var debounceWorkItem: DispatchWorkItem?
    private var isStarted = false

    private var dayChangeObserver: NSObjectProtocol?

    private init() {}

    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [activeEnergyType]) { success, error in
            completion(success, error)
        }
    }

    // MARK: - Public API
    func startObservingBurnedCaloriesChanges() {
        guard !isStarted else { return }
        isStarted = true

        resetIfNewDay()
        fetchIncrementalBurnedCalories()
        startObserver()

        dayChangeObserver = NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
            self?.handleMidnightRollOver()
        }
    }

    func stopObserving() {
        if let q = observerQuery { healthStore.stop(q) }
        if let q = anchoredQuery { healthStore.stop(q) }
        observerQuery = nil
        anchoredQuery = nil
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        if let obs = dayChangeObserver { NotificationCenter.default.removeObserver(obs) }
        dayChangeObserver = nil
        isStarted = false
    }

    func currentTotalTodayKCal() -> Double { totalTodayKCal }

    // MARK: - Historical API (unchanged behavior)
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.autoupdatingCurrent.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: caloriesType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard error == nil else { completion([]); return }
            var dailyBurnedCalories: [(date: String, burnedCalories: Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                if let sumQuantity = statistics.sumQuantity() {
                    let kcal = sumQuantity.doubleValue(for: .kilocalorie())
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: kcal))
                } else {
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: 0))
                }
            }
            completion(dailyBurnedCalories)
        }
        healthStore.execute(query)
    }

    // MARK: - Efficient Observer + Anchored Fetch
    private func startObserver() {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: { _, _ in })

        observerQuery = HKObserverQuery(sampleType: type, predicate: todayPredicate()) { [weak self] _, completionHandler, _ in
            guard let self else { completionHandler(); return }
            self.fetchIncrementalBurnedCalories { completionHandler() }
        }
        if let q = observerQuery { healthStore.execute(q) }
    }

    /// Fetch only the *new* samples since the last anchor and update the running total.
    private func fetchIncrementalBurnedCalories(completion: (() -> Void)? = nil) {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { completion?(); return }

        anchoredQuery = HKAnchoredObjectQuery(type: type,
                                              predicate: todayPredicate(),
                                              anchor: anchor,
                                              limit: HKObjectQueryNoLimit) { [weak self] _, samplesOrNil, _, newAnchor, _ in
            guard let self else { completion?(); return }
            self.anchor = newAnchor

            let samples = (samplesOrNil as? [HKQuantitySample]) ?? []
            if !samples.isEmpty {
                let added = samples.reduce(0.0) { partial, sample in
                    partial + sample.quantity.doubleValue(for: .kilocalorie())
                }
                self.totalTodayKCal += added
                self.postDebouncedUpdate()
            }
            completion?()
        }
        if let q = anchoredQuery { healthStore.execute(q) }
    }

    // MARK: - Helpers
    private func todayPredicate() -> NSPredicate? {
        let cal = Calendar.autoupdatingCurrent
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
    }

    private func handleMidnightRollOver() {
        anchor = nil
        totalTodayKCal = 0
        postDebouncedUpdate()
        fetchIncrementalBurnedCalories()
    }

    private func resetIfNewDay() {
        let key = "BurnedCaloriesManager.lastStartOfDay"
        let cal = Calendar.autoupdatingCurrent
        let todayStart = cal.startOfDay(for: Date())
        if let last = UserDefaults.standard.object(forKey: key) as? Date, cal.isDate(last, inSameDayAs: todayStart) {
        } else {
            anchor = nil
            totalTodayKCal = 0
        }
        UserDefaults.standard.set(todayStart, forKey: key)
    }

    private func postDebouncedUpdate() {
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            NotificationCenter.default.post(name: .healthKitBurnedCaloriesDataChanged,
                                            object: nil,
                                            userInfo: ["latestCalories": self.totalTodayKCal])
        }
        debounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) { work.perform() }
    }
}

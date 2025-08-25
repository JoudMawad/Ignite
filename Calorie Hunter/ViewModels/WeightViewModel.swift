import SwiftUI
import Combine

class WeightViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let weightManager = WeightManager()
    
    @Published var currentWeight: Double = 0.0
    
    init() {
        // Load the current weight from Core Data
        let weight = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
        self.currentWeight = weight
        
        requestAuthorization()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitChange),
                                               name: .healthKitWeightDataChanged,
                                               object: nil)
        updateWeightFromHistory()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { [weak self] success, error in
            guard let self = self else { return }
            if success {
                // Start background observation + delivery
                self.weightManager.startObservingWeightChanges()
                // Seed with any recent deltas (e.g., today/yesterday)
                let since = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                self.weightManager.fetchWeightDeltasAndStore(since: since) { [weak self] in
                    self?.updateWeightFromHistory()
                }
                // Initial historical daily averages import (light window)
                self.importHistoricalWeightsFromHealthKit()
            }
        }
    }
    
    func importHistoricalWeightsFromHealthKit() {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate) ?? Date.distantPast
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { [weak self] weightData in
            WeightHistoryManager.shared.importHistoricalWeights(weightData)
            self?.updateWeightFromHistory()
        }
    }
    
    private func updateWeight(with newValue: Double) {
        // Save to Core Data.
        WeightHistoryManager.shared.saveWeight(for: Date(), weight: newValue, writeToHealthKit: false)
        DispatchQueue.main.async {
            self.currentWeight = newValue
        }
    }
    
    func commitUserWeightChange(_ newValue: Double) {
        if abs(newValue - currentWeight) < 0.0001 { return }
        WeightHistoryManager.shared.saveWeight(for: Date(), weight: newValue, writeToHealthKit: true)
        DispatchQueue.main.async { self.currentWeight = newValue }
    }
    
    @objc private func handleHealthKitChange() {
        updateWeightFromHistory()
    }

    @objc private func handleAppForeground() {
        updateWeightFromHistory()
    }

    private func updateWeightFromHistory() {
        weightManager.fetchLatestWeight { [weak self] result in
            DispatchQueue.main.async {
                if let latest = result?.weight {
                    self?.currentWeight = latest
                } else {
                    // Fallback to most recent stored day if HealthKit has no sample
                    let fallback = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
                    self?.currentWeight = fallback
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

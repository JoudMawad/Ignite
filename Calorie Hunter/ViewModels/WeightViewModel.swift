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
                                               selector: #selector(handleDayChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
        updateWeightFromHistory()
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalWeightsFromHealthKit()
            }
        }
    }
    
    func importHistoricalWeightsFromHealthKit() {
        let startDate = Date.distantPast
        let endDate = Date()
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { weightData in
            WeightHistoryManager.shared.importHistoricalWeights(weightData)
            self.updateWeightFromHistory()
        }
    }
    
    private func updateWeight(with newValue: Double) {
        // Save to Core Data.
        WeightHistoryManager.shared.saveWeight(for: Date(), weight: newValue)
        DispatchQueue.main.async {
            self.currentWeight = newValue
        }
    }
    
    @objc private func handleDayChange() {
        updateWeightFromHistory()
    }
    
    private func updateWeightFromHistory() {
        let weight = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
        DispatchQueue.main.async {
            self.currentWeight = weight
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

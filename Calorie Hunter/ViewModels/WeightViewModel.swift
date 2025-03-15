import SwiftUI
import Combine

class WeightViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let weightManager = WeightManager()
    
    @Published var currentWeight: Double = 0.0
    
    init() {
        self.currentWeight = UserDefaults.standard.double(forKey: "weight")
        requestAuthorization()
        // Listen for a significant time change (typically a day change)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDayChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
        updateWeightFromHistory() // Initial update
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalWeightsFromHealthKit()
            } else {
                print("HealthKit authorization failed for weight: \(String(describing: error))")
            }
        }
    }
    
    func importHistoricalWeightsFromHealthKit() {
        // Fetch all available weight data.
        let startDate = Date.distantPast
        let endDate = Date()
        
        weightManager.fetchHistoricalDailyWeights(startDate: startDate, endDate: endDate) { weightData in
            WeightHistoryManager.shared.importHistoricalWeights(weightData)
            print("DEBUG: Imported all historical weight data into WeightHistoryManager.")
        }
    }
    
    private func updateWeight(with newValue: Double) {
        UserDefaults.standard.set(newValue, forKey: "weight")
        DispatchQueue.main.async {
            self.currentWeight = newValue
        }
    }
    
    @objc private func handleDayChange() {
        updateWeightFromHistory()
    }
    
    private func updateWeightFromHistory() {
        let weight = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
        updateWeight(with: weight)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

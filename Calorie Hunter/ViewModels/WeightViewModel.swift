import SwiftUI
import Combine

class WeightViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private let weightManager = WeightManager()
    private var timerCancellable: AnyCancellable?
    
    @Published var currentWeight: Double = 0.0
    
    init() {
        self.currentWeight = UserDefaults.standard.double(forKey: "weight")
        requestAuthorization()
        startWeightUpdates()
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
        // Fetch all available weight data by setting the start date to distantPast.
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
    
    private func startWeightUpdates() {
        timerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let weight = WeightHistoryManager.shared.weightForPeriod(days: 1).first?.weight ?? 0.0
                self.updateWeight(with: weight)
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

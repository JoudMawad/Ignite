//
//  BurnedCaloriesViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import Foundation
import Combine

class BurnedCaloriesViewModel: ObservableObject {
    private let healthKitManager = BurnedCaloriesManager.shared
    private let historyManager = BurnedCaloriesHistoryManager.shared
    private var timerCancellable: AnyCancellable?
    
    @Published var currentBurnedCalories: Double = 0
    
    init() {
        requestAuthorization()
        startBurnedCaloriesUpdates() // If you still want a periodic refresh
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHealthKitDataChanged),
                                               name: .healthKitBurnedCaloriesDataChanged,
                                               object: nil)
    }

    @objc private func handleHealthKitDataChanged() {
        // Fetch the latest burned calories from historyManager
        self.currentBurnedCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
    }
    
    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.importHistoricalBurnedCaloriesFromHealthKit()
            } else {
                // Handle authorization error if needed.
            }
        }
    }
    
    func importHistoricalBurnedCaloriesFromHealthKit() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = Date()
        
        healthKitManager.fetchHistoricalDailyBurnedCalories(startDate: startDate, endDate: endDate) { caloriesData in
            self.historyManager.importHistoricalBurnedCalories(caloriesData)
        }
    }
    
    /// Updates today's burned calories every 20 seconds.
    private func startBurnedCaloriesUpdates() {
        timerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentBurnedCalories = self.historyManager.burnedCaloriesForPeriod(days: 1).first?.burnedCalories ?? 0
            }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

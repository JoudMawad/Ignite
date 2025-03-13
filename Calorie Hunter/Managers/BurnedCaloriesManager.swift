//
//  BurnedCaloriesManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import HealthKit
import Foundation


class BurnedCaloriesManager {
    static let shared = BurnedCaloriesManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [activeEnergyType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchHistoricalDailyBurnedCalories(startDate: Date,
                                            endDate: Date,
                                            completion: @escaping ([(date: String, burnedCalories: Double)]) -> Void)
    {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: caloriesType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            guard error == nil else {
                completion([])
                return
            }
            
            var dailyBurnedCalories: [(date: String, burnedCalories: Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                if let sumQuantity = statistics.sumQuantity() {
                    let burnedCalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: burnedCalories))
                } else {
                    dailyBurnedCalories.append((date: dateStr, burnedCalories: 0))
                }
            }
            
            completion(dailyBurnedCalories)
        }
        
        healthStore.execute(query)
    }
    
    func startObservingBurnedCaloriesChanges() {
        guard let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let query = HKObserverQuery(sampleType: caloriesType, predicate: nil) { _, completionHandler, _ in
            NotificationCenter.default.post(name: .healthKitBurnedCaloriesDataChanged, object: nil)
            completionHandler()
        }
        healthStore.execute(query)
    }
}


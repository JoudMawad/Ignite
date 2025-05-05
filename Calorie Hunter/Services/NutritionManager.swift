
//
//  NutritionManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.05.25.
//

import HealthKit
import Foundation

/// Manages fetching and importing historical nutrition metrics (calories, protein, carbs, fat).
final class NutritionManager {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore = HealthKitManager.shared.healthStore) {
        self.healthStore = healthStore
    }

    /// Fetches historical daily calories from HealthKit between the specified dates.
    func fetchHistoricalCalories(startDate: Date,
                                 endDate: Date,
                                 completion: @escaping ([(date: String, calories: Double)]) -> Void)
    {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: calorieType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            var dailyCalories: [(String, Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current

            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                dailyCalories.append((date: dateStr, calories: value))
            })
            completion(dailyCalories)
        }
        healthStore.execute(query)
    }

    /// Fetches historical daily protein intake from HealthKit.
    func fetchHistoricalProtein(startDate: Date,
                                endDate: Date,
                                completion: @escaping ([(date: String, protein: Double)]) -> Void)
    {
        guard let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: proteinType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            var dailyProtein: [(String, Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current

            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .gram()) ?? 0
                dailyProtein.append((date: dateStr, protein: value))
            })
            completion(dailyProtein)
        }
        healthStore.execute(query)
    }

    /// Fetches historical daily carbohydrates intake from HealthKit.
    func fetchHistoricalCarbs(startDate: Date,
                              endDate: Date,
                              completion: @escaping ([(date: String, carbs: Double)]) -> Void)
    {
        guard let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: carbsType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            var dailyCarbs: [(String, Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current

            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .gram()) ?? 0
                dailyCarbs.append((date: dateStr, carbs: value))
            })
            completion(dailyCarbs)
        }
        healthStore.execute(query)
    }

    /// Fetches historical daily fat intake from HealthKit.
    func fetchHistoricalFat(startDate: Date,
                            endDate: Date,
                            completion: @escaping ([(date: String, fat: Double)]) -> Void)
    {
        guard let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal) else {
            completion([])
            return
        }
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: fatType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion([])
                return
            }
            var dailyFat: [(String, Double)] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current

            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dateStr = formatter.string(from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .gram()) ?? 0
                dailyFat.append((date: dateStr, fat: value))
            })
            completion(dailyFat)
        }
        healthStore.execute(query)
    }

    /// Fetches and imports all nutrition metrics into Core Data.
    func updateHistoricalNutrition(startDate: Date,
                                   endDate: Date,
                                   completion: @escaping () -> Void)
    {
        let group = DispatchGroup()
        var caloriesData: [(date: String, calories: Double)] = []
        var proteinData : [(date: String, protein: Double)] = []
        var carbsData   : [(date: String, carbs: Double)] = []
        var fatData     : [(date: String, fat: Double)] = []

        group.enter()
        fetchHistoricalCalories(startDate: startDate, endDate: endDate) {
            caloriesData = $0
            group.leave()
        }
        group.enter()
        fetchHistoricalProtein(startDate: startDate, endDate: endDate) {
            proteinData = $0
            group.leave()
        }
        group.enter()
        fetchHistoricalCarbs(startDate: startDate, endDate: endDate) {
            carbsData = $0
            group.leave()
        }
        group.enter()
        fetchHistoricalFat(startDate: startDate, endDate: endDate) {
            fatData = $0
            group.leave()
        }

        group.notify(queue: .main) {
            var merged: [(date: String, calories: Double, protein: Double, carbs: Double, fat: Double)] = []
            for entry in caloriesData {
                let date = entry.date
                let cal = entry.calories
                let prot = proteinData.first(where: { $0.date == date })?.protein ?? 0
                let carbs = carbsData.first(where: { $0.date == date })?.carbs ?? 0
                let ft = fatData.first(where: { $0.date == date })?.fat ?? 0
                merged.append((date: date, calories: cal, protein: prot, carbs: carbs, fat: ft))
            }
            NutritionHistoryManager.shared.importHistoricalNutrition(merged)
            completion()
        }
    }
}


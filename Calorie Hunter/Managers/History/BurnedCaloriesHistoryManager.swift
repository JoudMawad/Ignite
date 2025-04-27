//
//  BurnedCaloriesHistoryManager.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import Foundation
import Combine
import CoreData

// This manager keeps track of burned calories history and makes it easy to access and update.
// It's a singleton, so you can get the shared instance anywhere in your app.
class BurnedCaloriesHistoryManager: ObservableObject {
    // Shared instance for the entire app.
    static let shared = BurnedCaloriesHistoryManager()
    
    // The Core Data viewContext from your shared PersistenceController.
    private let viewContext = PersistenceController.shared.container.viewContext

    // MARK: - Importing Data

    /// Adds historical burned calories data to our stored history.
    /// - Parameter caloriesData: An array of tuples. Each tuple has a date string and the calories burned on that day.
    func importHistoricalBurnedCalories(_ caloriesData: [(date: String, burnedCalories: Double)]) {
        viewContext.perform { // <- This is the critical fix!
            for entry in caloriesData {
                let fetchRequest: NSFetchRequest<BurnedCaloriesEntry> = BurnedCaloriesEntry.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateString == %@", entry.date)
                do {
                    let results = try self.viewContext.fetch(fetchRequest)
                    let obj = results.first ?? BurnedCaloriesEntry(context: self.viewContext)
                    obj.dateString = entry.date
                    obj.burnedCalories = entry.burnedCalories
                } catch {
                    // Handle error if needed
                }
            }
            self.saveContext()
        }
    }
    
    /// Returns the burned calories logged locally for a specific date.
    /// - Parameter date: The date to query.
    /// - Returns: The calories burned on that date, or 0 if none recorded.
    func burnedCalories(on date: Date) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let key = formatter.string(from: date)
        let fetchRequest: NSFetchRequest<BurnedCaloriesEntry> = BurnedCaloriesEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateString == %@", key)
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first?.burnedCalories ?? 0
        } catch {
            return 0
        }
    }
    
    // MARK: - Retrieving Data

    /// Returns the burned calories for the last given number of days.
    /// - Parameter days: How many past days you want data for.
    /// - Returns: An array of tuples with the date and calories burned, ordered from the oldest date to the most recent.
    func burnedCaloriesForPeriod(days: Int) -> [(date: String, burnedCalories: Double)] {
        var results: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        for i in 0..<days {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatter.string(from: date)
                let fetchRequest: NSFetchRequest<BurnedCaloriesEntry> = BurnedCaloriesEntry.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateString == %@", dateString)
                do {
                    let entry = try viewContext.fetch(fetchRequest).first
                    let value = entry?.burnedCalories ?? 0
                    results.append((dateString, value))
                } catch {
                    results.append((dateString, 0))
                }
            }
        }
        return results.reversed()
    }
    
    // MARK: - Data Management

    /// Clears all the stored burned calories data.
    func clearData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BurnedCaloriesEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            // Handle error if needed
        }
    }
    
    /// Helper method to save the Core Data context.
    private func saveContext() {
        do {
            try viewContext.save()
            DispatchQueue.main.async { self.objectWillChange.send() }
        } catch {
            // Handle error if needed
        }
    }
}

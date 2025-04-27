//
//  Persistence.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 01.03.25.
//

import CoreData

// PersistenceController is responsible for setting up and managing the Core Data stack.
final class PersistenceController {
    // A shared instance for easy, global access to the persistence controller.
    static let shared = PersistenceController()

    // A preview instance that uses an in-memory store.
    // This is useful for SwiftUI previews and testing without saving data permanently.
    @MainActor
    static let preview: PersistenceController = {
        // Initialize a PersistenceController that doesn't write to disk.
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Create some sample data for preview purposes.
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date() // Each new item gets the current date as its timestamp.
        }
        do {
            try viewContext.save() // Save the preview data.
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // The NSPersistentContainer manages the Core Data stack.
    let container: NSPersistentContainer

    // The initializer sets up the persistent container.
    // If 'inMemory' is true, the data is stored temporarily in memory instead of on disk.
    init(inMemory: Bool = false) {
        // Initialize the container with the name of your Core Data model.
        container = NSPersistentContainer(name: "Calorie_Hunter")
        if inMemory {
            // When using an in-memory store, point the store URL to "/dev/null" so nothing is saved.
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // Load the persistent stores and handle any errors that might occur.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // If there's an error, crash the app with a detailed error message.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            // Seed default foods into the store
            self.seedPredefinedIfNeeded()
        })
        // Automatically merge changes from parent contexts into the view context.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Seeds Core Data with predefined foods if the store is empty.
    private func seedPredefinedIfNeeded() {
        let viewContext = container.viewContext
        viewContext.perform {
            let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
            let count = (try? viewContext.count(for: request)) ?? 0
            guard count == 0 else { return }
            for item in PredefinedFoods.foods {
                let entity = FoodEntity(context: viewContext)
                entity.id = item.id
                entity.name = item.name
                entity.calories = Double(item.calories)
                entity.protein = item.protein
                entity.carbs = item.carbs
                entity.fat = item.fat
                entity.grams = item.grams
                entity.mealType = item.mealType
                entity.date = Date.distantPast
                entity.isUserAdded = false
                entity.barcode = item.barcode
            }
            do {
                try viewContext.save()
            } catch {
                print("Error seeding predefined foods on viewContext: \(error)")
            }
        }
    }
}

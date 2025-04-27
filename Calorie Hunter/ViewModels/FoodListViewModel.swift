//
//  PreDefinedUserFoodsViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import Foundation
import CoreData

// UserPreDefinedFoodsViewModel is responsible for managing the list of predefined foods
// that the user has saved. It retrieves and updates the list from a shared data store.
class FoodListViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var foods: [FoodItem] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        loadFoods()
    }
    
    /// Loads the predefined foods from the shared data store.
    func loadFoods() {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        // Optional: sort by name
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntity.name, ascending: true)]
        do {
            let entities = try context.fetch(request)
            foods = entities.map { entity in
                FoodItem(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    calories: Int(entity.calories),
                    protein: entity.protein,
                    carbs: entity.carbs,
                    fat: entity.fat,
                    grams: entity.grams,
                    mealType: entity.mealType ?? "",
                    date: entity.date ?? Date(),
                    isUserAdded: entity.isUserAdded,
                    barcode: entity.barcode
                )
            }
        } catch {
            print("Error fetching foods: \(error)")
            foods = []
        }
    }
    
    /// Removes a food item from the shared data store using its unique identifier.
    /// - Parameter id: The unique identifier of the food item to remove.
    func removeFood(by id: UUID) {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            try context.save()
            loadFoods()
        } catch {
            print("Error deleting food: \(error)")
        }
    }
    
    /// Deletes one or more food items at the specified indices.
    /// - Parameter offsets: The set of indices corresponding to the food items to delete.
    func deleteFood(at offsets: IndexSet) {
        for index in offsets {
            let id = foods[index].id
            removeFood(by: id)
        }
    }
    
    /// Updates a predefined food item in the shared store.
    /// - Parameter updated: The FoodItem with updated properties.
    func updateFood(_ updated: FoodItem) {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", updated.id as CVarArg)
        do {
            if let entity = try context.fetch(request).first {
                entity.name = updated.name
                entity.calories = Double(updated.calories)
                entity.protein = updated.protein
                entity.carbs = updated.carbs
                entity.fat = updated.fat
                entity.grams = updated.grams
                entity.mealType = updated.mealType
                try context.save()
                loadFoods()
            }
        } catch {
            print("Error updating food: \(error)")
        }
    }
    /// Adds a new FoodItem into Core Data and refreshes the list.
    func addFood(_ food: FoodItem) {
        let entity = FoodEntity(context: context)
        entity.id = food.id
        entity.name = food.name
        entity.calories = Double(food.calories)
        entity.protein = food.protein
        entity.carbs = food.carbs
        entity.fat = food.fat
        entity.grams = food.grams
        entity.mealType = food.mealType
        entity.date = food.date
        entity.isUserAdded = food.isUserAdded
        entity.barcode = food.barcode
        do {
            try context.save()
        } catch {
            print("Error saving new food: \(error)")
        }
        loadFoods()
    }
}

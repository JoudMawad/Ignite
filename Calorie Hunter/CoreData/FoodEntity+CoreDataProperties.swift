//
//  FoodEntity+CoreDataProperties.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 28.04.25.
//
//

import Foundation
import CoreData


extension FoodEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntity> {
        return NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var calories: Double
    @NSManaged public var carbs: Double
    @NSManaged public var date: Date?
    @NSManaged public var fat: Double
    @NSManaged public var grams: Double
    @NSManaged public var id: UUID?
    @NSManaged public var isUserAdded: Bool
    @NSManaged public var mealType: String?
    @NSManaged public var name: String?
    @NSManaged public var protein: Double
    @NSManaged public var consumptions: NSSet?

}

// MARK: Generated accessors for consumptions
extension FoodEntity {

    @objc(addConsumptionsObject:)
    @NSManaged public func addToConsumptions(_ value: ConsumptionEntity)

    @objc(removeConsumptionsObject:)
    @NSManaged public func removeFromConsumptions(_ value: ConsumptionEntity)

    @objc(addConsumptions:)
    @NSManaged public func addToConsumptions(_ values: NSSet)

    @objc(removeConsumptions:)
    @NSManaged public func removeFromConsumptions(_ values: NSSet)

}

extension FoodEntity : Identifiable {

}

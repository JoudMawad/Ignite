//
//  FoodEntity+CoreDataProperties.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 27.04.25.
//
//

import Foundation
import CoreData


extension FoodEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntity> {
        return NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var calories: Double
    @NSManaged public var protein: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var grams: Double
    @NSManaged public var mealType: String?
    @NSManaged public var date: Date?
    @NSManaged public var isUserAdded: Bool
    @NSManaged public var barcode: String?
    @NSManaged public var id: UUID?
    @NSManaged public var consumptions: ConsumptionEntity?

}

extension FoodEntity : Identifiable {

}

//
//  ConsumptionEntity+CoreDataProperties.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 27.04.25.
//
//

import Foundation
import CoreData


extension ConsumptionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConsumptionEntity> {
        return NSFetchRequest<ConsumptionEntity>(entityName: "ConsumptionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dateEaten: Date?
    @NSManaged public var gramsConsumed: Double
    @NSManaged public var mealType: String?
    @NSManaged public var food: FoodEntity?

}

extension ConsumptionEntity : Identifiable {

}

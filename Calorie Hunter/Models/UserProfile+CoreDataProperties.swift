import Foundation
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {
}

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var gender: String?
    @NSManaged public var age: Int32
    @NSManaged public var height: Int32
    @NSManaged public var dailyCalorieGoal: Int32
    @NSManaged public var startWeight: Double
    @NSManaged public var currentWeight: Double
    @NSManaged public var goalWeight: Double
    @NSManaged public var profileImageData: Data?
    @NSManaged public var dailyStepsGoal: Int32
    @NSManaged public var dailyBurnedCaloriesGoal: Int32
}



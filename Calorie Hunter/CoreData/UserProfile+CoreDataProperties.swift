import Foundation
import CoreData

// This is the Core Data class for a user's profile.
// It stores personal details like name, age, height, and various goals.
@objc(UserProfile)
public class UserProfile: NSManagedObject {
}

// MARK: - Core Data Properties for UserProfile

extension UserProfile {
    // A convenience method to create a fetch request for UserProfile objects.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    
    // MARK: - Attributes

    // The user's name.
    @NSManaged public var name: String?
    // The user's gender.
    @NSManaged public var gender: String?
    // The user's age stored as a 32-bit integer.
    @NSManaged public var age: Int32
    // The user's height stored as a 32-bit integer.
    @NSManaged public var height: Int32
    // The user's daily calorie goal.
    @NSManaged public var dailyCalorieGoal: Int32
    // The user's starting weight.
    @NSManaged public var startWeight: Double
    // The user's current weight.
    @NSManaged public var currentWeight: Double
    // The user's goal weight.
    @NSManaged public var goalWeight: Double
    // The user's profile image stored as binary data.
    @NSManaged public var profileImageData: Data?
    // The user's daily steps goal.
    @NSManaged public var dailyStepsGoal: Int32
    // The user's daily burned calories goal.
    @NSManaged public var dailyBurnedCaloriesGoal: Int32
    // The user's daily Water Intake goal.
    @NSManaged public var dailyWaterGoal: Double
    /// The user's weekly weight change goal (kg per week; negative to lose, positive to gain).
    @NSManaged public var weeklyWeightChangeGoal: Double
    /// The user's activity level (0=sedentary, 1=lightlyActive, 2=moderatelyActive, 3=veryActive).
    @NSManaged public var activityLevel: Int32
    
    
}

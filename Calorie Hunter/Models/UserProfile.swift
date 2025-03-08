import Foundation

struct UserProfile: Codable {
    var name: String
    var Gender: String
    var age: Int
    var height: Int
    var dailyCalorieGoal: Int
    var startWeight: Double
    var currentWeight: Double
    var goalWeight: Double
    var profileImageData: Data? // Optional image data property
}

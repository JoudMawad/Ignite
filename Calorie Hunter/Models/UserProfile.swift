import Foundation

struct UserProfile: Codable {
    var name: String
    var dailyCalorieGoal: Int
    var startWeight: Double
    var currentWeight: Double
    var goalWeight: Double
    var profileImageData: Data? // Optional image data property
}

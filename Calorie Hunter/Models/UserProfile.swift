import Foundation

struct UserProfile: Codable {
    var name: String
    var dailyCalorieGoal: Int
    var startWeight: Int
    var currentWeight: Int
    var goalWeight: Int
}

import SwiftUI

class UserProfileViewModel: ObservableObject {
    @AppStorage("userProfile") private var userData: Data?

    @Published var name: String = ""
    @Published var dailyCalorieGoal: Int = 1500
    @Published var startWeight: Int = 70
    @Published var currentWeight: Int = 70
    @Published var goalWeight: Int = 65

    init() {
        loadProfile()
    }

    // ✅ Load profile from AppStorage
    func loadProfile() {
        if let savedData = userData, let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            DispatchQueue.main.async {
                self.name = decodedProfile.name
                self.dailyCalorieGoal = decodedProfile.dailyCalorieGoal
                self.startWeight = decodedProfile.startWeight
                self.currentWeight = decodedProfile.currentWeight
                self.goalWeight = decodedProfile.goalWeight
            }
        }
    }

    // ✅ Save profile to AppStorage
    func saveProfile() {
        let profile = UserProfile(
            name: self.name,
            dailyCalorieGoal: self.dailyCalorieGoal,
            startWeight: self.startWeight,
            currentWeight: self.currentWeight,
            goalWeight: self.goalWeight
        )

        if let encodedData = try? JSONEncoder().encode(profile) {
            userData = encodedData
        }
    }

    // ✅ Fix: Ensure weight updates are properly saved
    func updateCurrentWeight(_ newWeight: Int) {
        DispatchQueue.main.async {
            self.currentWeight = newWeight
            self.saveProfile()
        }
    }
}

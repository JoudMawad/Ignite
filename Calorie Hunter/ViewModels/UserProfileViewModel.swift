import SwiftUI

class UserProfileViewModel: ObservableObject {
    @AppStorage("userProfile") private var userData: Data?

    @Published var name: String = ""
    @Published var gender: String = ""
    @Published var age: Int = 25
    @Published var height: Int = 170
    @Published var dailyCalorieGoal: Int = 1500
    @Published var startWeight: Double = 70.0
    @Published var currentWeight: Double = 70.0
    @Published var goalWeight: Double = 65.0

    init() {
        loadProfile()
    }

    // Load profile from AppStorage.
    func loadProfile() {
        if let savedData = userData,
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            DispatchQueue.main.async {
                self.name = decodedProfile.name
                self.gender = decodedProfile.Gender
                self.age = decodedProfile.age
                self.height = decodedProfile.height
                self.dailyCalorieGoal = decodedProfile.dailyCalorieGoal
                self.startWeight = decodedProfile.startWeight
                self.currentWeight = decodedProfile.currentWeight
                self.goalWeight = decodedProfile.goalWeight
            }
        }
    }

    // Save profile to AppStorage.
    func saveProfile() {
        let profile = UserProfile(
            name: self.name,
            Gender: self.gender,
            age: self.age,
            height: self.height,
            dailyCalorieGoal: self.dailyCalorieGoal,
            startWeight: self.startWeight,
            currentWeight: self.currentWeight,
            goalWeight: self.goalWeight,
            profileImageData: nil // You could update this if you have image data.
        )

        if let encodedData = try? JSONEncoder().encode(profile) {
            userData = encodedData
        }
    }

    // Update current weight and save profile along with weight history.
    func updateCurrentWeight(_ newWeight: Double) {
        DispatchQueue.main.async {
            self.currentWeight = newWeight
            self.saveProfile() // Saves to UserDefaults.
            
            let weightHistoryManager = WeightHistoryManager()
            weightHistoryManager.saveDailyWeight(currentWeight: newWeight)
        }
    }
}

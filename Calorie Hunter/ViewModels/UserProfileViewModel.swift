import SwiftUI

class UserProfileViewModel: ObservableObject {
    @AppStorage("userProfile") private var userData: Data?

    @Published var profile: UserProfile = UserProfile(
        name: "",
        dailyCalorieGoal: 1500,
        startWeight: 70,
        currentWeight: 70,
        goalWeight: 65
    )

    init() {
        loadProfile()
    }

    //Load profile from AppStorage
    func loadProfile() {
        if let savedData = userData {
            if let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
                self.profile = decodedProfile
            }
        }
    }

    //Save profile to AppStorage
    func saveProfile() {
        if let encodedData = try? JSONEncoder().encode(profile) {
            userData = encodedData
        }
    }

    //Get App Version and Build Number
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

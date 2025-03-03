import SwiftUI

struct UserProfileView: View {
    @AppStorage("userName") private var userName: String = "User Profile"
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Int = 1500
    @AppStorage("startWeight") private var startWeight: Int = 70
    @AppStorage("userWeight") private var userWeight: Int = 70
    @Environment(\.dismiss) var dismiss

    // ✅ Get App Version and Build Number
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // ✅ Section for User Name
                    Section(header: Text("Personal Information")) {
                        TextField("Enter your name", text: $userName)
                    }

                    // ✅ Section for Weight & Goals
                    Section(header: Text("Health Goals")) {
                        Stepper("Starting Weight: \(startWeight) kg", value: $startWeight, in: 40...200, step: 1)
                        Stepper("Current Weight: \(userWeight) kg", value: $userWeight, in: 40...200, step: 1)
                        Stepper("Calorie Goal: \(dailyCalorieGoal) kcal", value: $dailyCalorieGoal, in: 1000...4000, step: 50)
                    }
                }

                // ✅ App Version Display at the Bottom
                Text("Version \(appVersion) (Build \(buildNumber))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
            }
            .navigationTitle(userName.isEmpty ? "User Profile" : userName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}

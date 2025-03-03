import SwiftUI

struct UserProfileView: View {
    @AppStorage("userName") private var userName: String = "User Profile" // ✅ Stores user's name
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Int = 1500
    @AppStorage("startWeight") private var startWeight: Int = 70 // ✅ Start weight with Stepper
    @AppStorage("userWeight") private var userWeight: Int = 70
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // ✅ Section for User Name
                Section(header: Text("Personal Information")) {
                    TextField("Enter your name", text: $userName)
                }

                // ✅ Section for Weight & Goals
                Section(header: Text("Health Goals")) {
                    Stepper("Starting Weight: \(startWeight) kg", value: $startWeight, in: 40...200, step: 1) // ✅ Matches style
                    Stepper("Current Weight: \(userWeight) kg", value: $userWeight, in: 40...200, step: 1)
                    Stepper("Calorie Goal: \(dailyCalorieGoal) kcal", value: $dailyCalorieGoal, in: 1000...4000, step: 50)
                }
            }
            .navigationTitle(userName.isEmpty ? "User Profile" : userName) // ✅ Shows user's name in title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // ✅ Close the profile page
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = UserProfileViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    //Section for User Name
                    Section(header: Text("Personal Information")) {
                        TextField("Enter your name", text: $viewModel.profile.name, onEditingChanged: { _ in
                            viewModel.saveProfile()
                        })
                    }

                    //Section for Weight & Goals
                    Section(header: Text("Health Goals")) {
                        Stepper("Start Weight: \(viewModel.profile.startWeight) kg", value: $viewModel.profile.startWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Current Weight: \(viewModel.profile.currentWeight) kg", value: $viewModel.profile.currentWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Goal Weight: \(viewModel.profile.goalWeight) kg", value: $viewModel.profile.goalWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Calorie Goal: \(viewModel.profile.dailyCalorieGoal) kcal", value: $viewModel.profile.dailyCalorieGoal, in: 1000...4000, step: 50, onEditingChanged: { _ in viewModel.saveProfile() })
                    }
                }
                .frame(maxHeight: .infinity) // Ensures form takes most space

            }
            .navigationTitle(viewModel.profile.name.isEmpty ? "User Profile" : viewModel.profile.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            //Ensures the app version is always at the bottom, even on scrolling
            .safeAreaInset(edge: .bottom) {
                Text("Version \(viewModel.appVersion) (Build \(viewModel.buildNumber))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    UserProfileView()
}

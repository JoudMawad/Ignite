import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel  // ✅ Use @ObservedObject to receive shared instance

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // ✅ Section for User Name
                    Section(header: Text("Personal Information")) {
                        TextField("Enter your name", text: $viewModel.name, onEditingChanged: { _ in
                            viewModel.saveProfile()
                        })
                    }

                    // ✅ Section for Weight & Goals
                    Section(header: Text("Health Goals")) {
                        Stepper("Start Weight: \(viewModel.startWeight) kg", value: $viewModel.startWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Current Weight: \(viewModel.currentWeight) kg", value: $viewModel.currentWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Goal Weight: \(viewModel.goalWeight) kg", value: $viewModel.goalWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                        Stepper("Calorie Goal: \(viewModel.dailyCalorieGoal) kcal", value: $viewModel.dailyCalorieGoal, in: 1000...4000, step: 50, onEditingChanged: { _ in viewModel.saveProfile() })
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle(viewModel.name.isEmpty ? "User Profile" : viewModel.name)
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
    UserProfileView(viewModel: UserProfileViewModel()) // ✅ Pass a ViewModel instance for preview
}

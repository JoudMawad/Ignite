import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("").foregroundColor(.white)) {
                        ZStack {
                            Color.black //Forces background to be black
                            TextField("Enter your name", text: $viewModel.name, onEditingChanged: { _ in
                                viewModel.saveProfile()
                            })
                            .background(Color.black) // Forces black background
                            .foregroundColor(.white) // white text
                            .font(.system(size: 40, weight: .bold))
                        }
                        .listRowBackground(Color.black) //Ensures row stays black
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    
                    Section(header: Text("Health Goals").foregroundColor(.white)) {
                        Stepper("Start Weight: \(viewModel.startWeight) kg", value: $viewModel.startWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                            .foregroundColor(.white)
                            .listRowBackground(Color.black)
                        Stepper("Current Weight: \(viewModel.currentWeight) kg", value: $viewModel.currentWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                            .foregroundColor(.white)
                            .listRowBackground(Color.black)
                        Stepper("Goal Weight: \(viewModel.goalWeight) kg", value: $viewModel.goalWeight, in: 40...200, step: 1, onEditingChanged: { _ in viewModel.saveProfile() })
                            .foregroundColor(.white)
                            .listRowBackground(Color.black)
                        Stepper("Calorie Goal: \(viewModel.dailyCalorieGoal) kcal", value: $viewModel.dailyCalorieGoal, in: 1000...4000, step: 50, onEditingChanged: { _ in viewModel.saveProfile() })
                            .foregroundColor(.white)
                            .listRowBackground(Color.black)
                    }
                }
                .scrollContentBackground(.hidden) // Hides default gray form background
                .background(Color.black) //Full black background
            }
            .navigationTitle(viewModel.name.isEmpty ? "" : viewModel.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) //Ensures full black background
        }
    }
}

#Preview {
    UserProfileView(viewModel: UserProfileViewModel()) //Pass a ViewModel instance for preview
}

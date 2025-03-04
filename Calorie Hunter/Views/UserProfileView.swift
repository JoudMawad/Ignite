import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    NameSection(viewModel: viewModel)
                    HealthGoalsSection(viewModel: viewModel)
                }
                .scrollContentBackground(.hidden) // Ensure there is no gray background
                .background(Color.black) // Ensure the background now is black
            }
            .navigationTitle(viewModel.name.isEmpty ? "" : viewModel.name)
        }
        
    }
}

struct NameSection: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        Section(header: Text("").foregroundColor(.white)) {
            ZStack {
                Color.black
                TextField("Enter your name", text: $viewModel.name, onEditingChanged: { _ in
                    viewModel.saveProfile()
                })
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .bold))
            }
            .listRowBackground(Color.black) // Name box is Black
        }
    }
}

struct HealthGoalsSection: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        Section() {
            VStack {
                WeightPicker(title: "Start Weight:", selection: $viewModel.startWeight)
                WeightPicker(title: "Current Weight:", selection: $viewModel.currentWeight)
                WeightPicker(title: "Goal Weight:", selection: $viewModel.goalWeight)
                Stepper("Calorie Goal: \(viewModel.dailyCalorieGoal) kcal",
                        value: $viewModel.dailyCalorieGoal,
                        in: 1000...4000,
                        step: 50,
                        onEditingChanged: { _ in viewModel.saveProfile() })
                    .foregroundColor(.white)            }
        }
        .listRowBackground(Color.black) // Ensure the Health Goal box is Black
    }
}

struct WeightPicker: View {
    let title: String
    @Binding var selection: Double
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Picker("", selection: $selection) {
                ForEach(Array(stride(from: 40.0, through: 200.9, by: 0.1)), id: \.self) { weight in
                    Text(String(format: "%.1f kg", weight)).tag(weight)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100, height: 50)
            .clipped()
            .tint(Color.black)
        }
    }
}

#Preview {
    UserProfileView(viewModel: UserProfileViewModel())
}

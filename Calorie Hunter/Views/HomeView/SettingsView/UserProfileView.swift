import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel
    @StateObject var imageVM = ProfileImageViewModel()
    @State private var isShowingImagePicker = false

    var body: some View {
        VStack(spacing: 20) {
            // Group profile picture and name together
            VStack(spacing: 8) {
                // Profile image with an overlay edit button
                ZStack(alignment: .bottomTrailing) {
                    if let profileImage = imageVM.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: Color.cyan.opacity(0.7), radius: 5, x: 0, y: 0)
                        
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: Color.cyan.opacity(0.7), radius: 5, x: 0, y: 0)
                    }
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .background(Color.white.clipShape(Circle()))
                    }
                    .offset(x: -8, y: -8)
                }
                
                // Name text field positioned directly under the profile image
                TextField("Enter your name", text: $viewModel.name, onEditingChanged: { _ in
                    viewModel.saveProfile()
                })
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .bold))
                .padding(.horizontal)
            }
            .padding(.top, 40)
            
            // Health goal fields
            VStack(spacing: 8) {
                HealthGoalTextField(title: "Start Weight:", value: $viewModel.startWeight)
                HealthGoalTextField(title: "Current Weight:", value: $viewModel.currentWeight)
                HealthGoalTextField(title: "Goal Weight:", value: $viewModel.goalWeight)
                HealthGoalTextField(
                    title: "Calorie Goal:",
                    value: Binding<Double>(
                        get: { Double(viewModel.dailyCalorieGoal) },
                        set: { viewModel.dailyCalorieGoal = Int($0) }
                    )
                )
            }
            .background(Color.black)
            .padding(.top, 35)
            .padding(.horizontal, 60)
            .padding(.bottom, 100)
            .background(
                RoundedRectangle(cornerRadius: 60)
                    .fill(Color(UIColor.black))
                    .shadow(color: Color.cyan.opacity(0.3), radius: 14, x: 0, y: 10)
                    .padding(.horizontal, 30)

            )
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onTapGesture { hideKeyboard() }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $imageVM.profileImage)
        }
    }
}

struct HealthGoalTextField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", value: $value, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 19, weight: .light, design: .rounded))
                    .frame(width: 80)
            }
            Color.clear
                .frame(width: 250, height: 1)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    UserProfileView(viewModel: UserProfileViewModel())
}

import SwiftUI

// MARK: - UserProfileView
/// A view that displays the user profile including profile image, personal information,
/// and health goal fields.
struct UserProfileView: View {
    // Environment values for dismissing the view and detecting color scheme.
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Observed view model for user profile data.
    @ObservedObject var viewModel: UserProfileViewModel
    
    // StateObject to manage the profile image and handle image updates.
    @StateObject var imageVM = ProfileImageViewModel()
    
    // State flag to present the image picker modal.
    @State private var isShowingImagePicker = false

    var body: some View {
        // ScrollView to support content scrolling.
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Profile Section
                profileSection
                
                // MARK: Personal Information Section
                personalInfoSection
                
                Spacer()
                
                // MARK: Health Goal Fields Section
                healthGoalSection
                
                Spacer()
            }
            // Set the overall background based on the color scheme.
            .background(colorScheme == .dark ? Color.black : Color.white)
            // Dismiss keyboard when tapping outside text fields.
            .onTapGesture { hideKeyboard() }
            // Present the image picker when triggered.
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $imageVM.profileImage)
            }
        }
    }
    
    // MARK: - Profile Section
    /// Displays the profile image with a pencil icon button for editing and the user's name.
    private var profileSection: some View {
        VStack(spacing: 8) {
            // ZStack to overlay the pencil button on the profile image.
            ZStack(alignment: .bottomTrailing) {
                // Display either the selected profile image or a default system image.
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
                // Pencil icon button to trigger the image picker.
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
            // Display the user's name below the profile image.
            Text(viewModel.name)
                .foregroundColor(.primary)
                .font(.system(size: 40, weight: .bold))
        }
        .padding(.top, 40)
    }
    
    // MARK: - Personal Information Section
    /// Provides editable fields for personal details such as name, age, height, and gender.
    private var personalInfoSection: some View {
        VStack(spacing: 12) {
            // Editable text field for name.
            CustomTextField(title: "Name:", value: $viewModel.name, onCommit: {
                viewModel.saveProfile()
            })
            
            // Editable text field for age with conversion binding.
            CustomTextField(
                title: "Age:",
                value: Binding<Double>(
                    get: { Double(viewModel.age) },
                    set: { viewModel.age = Int($0) }
                ),
                onCommit: {
                    viewModel.saveProfile()
                }
            )
            
            // Editable text field for height with conversion binding.
            CustomTextField(
                title: "Height:",
                value: Binding<Double>(
                    get: { Double(viewModel.height) },
                    set: { viewModel.height = Int($0) }
                ),
                onCommit: {
                    viewModel.saveProfile()
                }
            )
            
            // Gender picker using a segmented control.
            HStack {
                Text("Gender")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("", selection: $viewModel.gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
                // Save profile when gender changes.
                .onChange(of: viewModel.gender) { newGender, oldGender in
                    viewModel.saveProfile()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)
        }
        // Background for personal info section based on color scheme.
        .background(colorScheme == .dark ? Color.black : Color.white)
        .padding(.top, 35)
        .padding(.horizontal, 60)
        .padding(.bottom, 100)
        // Rounded rectangle background with shadow.
        .background(
            RoundedRectangle(cornerRadius: 60)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 5, x: 0, y: 4)
                .padding(.horizontal, 30)
        )
    }
    
    // MARK: - Health Goal Section
    /// Displays text fields for entering health goals like weights and daily calorie goal.
    private var healthGoalSection: some View {
        VStack(spacing: 8) {
            // Editable text field for start weight.
            CustomTextField(title: "Start Weight:", value: $viewModel.startWeight, onCommit: {
                viewModel.saveProfile()
            })
            // Editable text field for current weight.
            CustomTextField(title: "Current Weight:", value: $viewModel.currentWeight, onCommit: {
                viewModel.saveProfile()
            })
            // Editable text field for goal weight.
            CustomTextField(title: "Goal Weight:", value: $viewModel.goalWeight, onCommit: {
                viewModel.saveProfile()
            })
            // Editable text field for daily calorie goal with conversion binding.
            CustomTextField(
                title: "Calorie Goal:",
                value: Binding<Double>(
                    get: { Double(viewModel.dailyCalorieGoal) },
                    set: { viewModel.dailyCalorieGoal = Int($0) }
                ),
                onCommit: {
                    viewModel.saveProfile()
                }
            )
        }
        // Background for health goal section based on color scheme.
        .background(colorScheme == .dark ? Color.black : Color.white)
        .padding(.top, 35)
        .padding(.horizontal, 60)
        .padding(.bottom, 60)
        // Rounded rectangle background.
        .background(
            RoundedRectangle(cornerRadius: 60)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 5, x: 0, y: 4)
                .padding(.horizontal, 30)
        )
    }
}

// MARK: - CustomTextField
/// A customizable text field view that adjusts based on the generic type of the value.
struct CustomTextField<Value>: View {
    let title: String
    @Binding var value: Value
    @Environment(\.colorScheme) var colorScheme
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                // Title for the text field.
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Render a TextField based on the type of the bound value.
                if Value.self == Double.self {
                    TextField("",
                              value: Binding(
                                get: { value as! Double },
                                set: { newValue in value = newValue as! Value }
                              ),
                              format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 19, weight: .light, design: .rounded))
                        .frame(width: 80)
                        .onSubmit {
                            onCommit?()
                        }
                        .onChange(of: value as! Double) { newValue, oldValue in
                            onCommit?()
                        }
                } else if Value.self == String.self {
                    TextField("",
                              text: Binding(
                                get: { value as! String },
                                set: { newValue in value = newValue as! Value }
                              ))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 19, weight: .light, design: .rounded))
                        .frame(width: 150)
                        .onSubmit {
                            onCommit?()
                        }
                } else {
                    // Fallback view if type is unsupported.
                    EmptyView()
                }
            }
            // Underline effect using a clear color overlay with gradient.
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

// MARK: - View Extension
extension View {
    /// Hides the keyboard by resigning the first responder status.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

// MARK: - Preview Provider
#Preview {
    UserProfileView(viewModel: UserProfileViewModel())
}

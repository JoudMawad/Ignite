import SwiftUI

/// The first step of the onboarding process where the user builds their profile.
/// This view displays an animated title, input fields for profile details (profile picture, name, gender, age),
/// and a "Next" button to proceed if all required fields are valid. A custom alert is shown if validation fails.
struct OnboardingStep1View: View {
    // MARK: - Observed Objects
    
    /// The view model that holds user profile data.
    @ObservedObject var viewModel: UserProfileViewModel
    
    /// A view model dedicated to handling profile image logic.
    @StateObject var imageVM = ProfileImageViewModel()
    
    // MARK: - Environment
    
    /// Access the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Local State
    
    /// Toggles the display of input fields.
    @State private var showContent = false
    /// Toggles the display of the "Next" button.
    @State private var showContent1 = false
    /// Tracks if the title animation has completed to prevent repeat triggering.
    @State private var hasCompletedAnimation = false
    /// Controls navigation to the next onboarding step.
    @State private var navigateToStep2 = false
    /// Controls the display of a custom alert when validation fails.
    @State private var showCustomAlert = false
    
    /// Toggles the image picker sheet.
    @State private var isShowingImagePicker = false
    
    /// Blur effect for input fields animation.
    @State private var inputBlur: CGFloat = 10
    /// Blur effect for button animation.
    @State private var buttonBlur: CGFloat = 10

    // MARK: - Validation
    
    /// Checks that Name and Gender are not empty and Age is greater than 0.
    var isStep1Valid: Bool {
        return !viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !viewModel.gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               viewModel.age > 0
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main content wrapped in a VStack.
            VStack {
                Spacer()
                
                // MARK: Animated Title
                // Display a typewriter-style animated welcome message.
                TypewriterText(fullText: "Welcome. Let's build your profile.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        // After the typewriter animation completes, reveal the input fields.
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent = true
                            }
                        }
                        // Delay the appearance of the Next button slightly.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent1 = true
                            }
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                // MARK: Input Fields
                if showContent {
                    VStack(spacing: 20) {
                        // Profile picture input cell.
                        OnboardingProfilePicCell(
                            isShowingImagePicker: $isShowingImagePicker,
                            profileImage: $imageVM.profileImage
                        )
                        // Text input for the user's name.
                        OnboardingInputCellString(
                            title: "Name",
                            placeholder: "....",
                            systemImageName: "person.fill",
                            value: $viewModel.name
                        )
                        // Picker input for selecting gender.
                        OnboardingInputCellPicker(
                            title: "Gender",
                            systemImageName: "person.2.fill",
                            options: ["Male", "Female", "Other"],
                            selection: $viewModel.gender
                        )
                        // Numeric input for the user's age.
                        OnboardingInputCellInt(
                            title: "Age",
                            placeholder: "....",
                            systemImageName: "number.circle",
                            value: $viewModel.age
                        )
                    }
                    // Fade in the input fields using an opacity transition.
                    .transition(.opacity)
                    // Apply an initial blur that animates out.
                    .blur(radius: inputBlur)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            inputBlur = 0
                        }
                    }
                }
                
                Spacer()
                
                // MARK: Next Button
                if showContent1 {
                    Button(action: {
                        // Validate input fields.
                        if isStep1Valid {
                            // Provide haptic feedback for success.
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            // Proceed to the next onboarding step.
                            navigateToStep2 = true
                        } else {
                            // Provide haptic feedback for error.
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            // Display a custom alert if fields are incomplete.
                            withAnimation {
                                showCustomAlert = true
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .transition(.opacity)
                    .blur(radius: buttonBlur)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            buttonBlur = 0
                        }
                    }
                }
                
                Spacer()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            // Dismiss the keyboard when tapping outside input fields.
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            // Blur the main content if the custom alert is active.
            .blur(radius: showCustomAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: showCustomAlert)
            
            // MARK: Custom Alert Overlay
            if showCustomAlert {
                // Semi-transparent background overlay to highlight the alert.
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showCustomAlert = false
                        }
                    }
                
                // Display the custom alert view.
                CustomAlert(
                    title: "Incomplete Details",
                    message: "It looks like some fields are missing. Please fill in your name, gender, and age to proceed."
                ) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCustomAlert = false
                    }
                }
                // Use a custom transition for the alert.
                .transition(.blurScale)
                // Ensure the alert appears above other content.
                .zIndex(1)
            }
        }
        // MARK: Navigation to Next Onboarding Step
        .navigationDestination(isPresented: $navigateToStep2) {
            OnboardingStep2View(viewModel: viewModel)
        }
        // MARK: Image Picker Sheet
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $imageVM.profileImage)
        }
    }
}

// MARK: - Preview
struct OnboardingStep1View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { // Using NavigationStack for iOS 16+
            let context = PersistenceController.preview.container.viewContext
            let viewModel = UserProfileViewModel(context: context)
            OnboardingStep1View(viewModel: viewModel)
        }
    }
}

// MARK: - UIApplication Extension
// This extension allows dismissing the keyboard when the user taps outside text fields.
import UIKit
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

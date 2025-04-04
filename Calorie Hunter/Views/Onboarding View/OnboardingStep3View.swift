import SwiftUI

/// The third step of the onboarding process where the user sets their personal goals.
/// This view displays an animated typewriter prompt, input fields for various goals,
/// and a "Finish" button that completes the onboarding process if validation passes.
/// A custom alert is shown if required fields are incomplete.
struct OnboardingStep3View: View {
    // MARK: - Observed Objects and AppStorage
    
    /// The view model containing user profile data and goal settings.
    @ObservedObject var viewModel: UserProfileViewModel
    
    /// A persistent flag indicating whether onboarding has been completed.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // MARK: - Environment
    
    /// Access the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Local State
    
    /// Controls the visibility of input fields after the typewriter animation.
    @State private var showContent = false
    /// Controls the visibility of the "Finish" button.
    @State private var showContent1 = false
    /// Prevents repeating the animation.
    @State private var hasCompletedAnimation = false
    /// Controls the display of a custom alert when validation fails.
    @State private var showCustomAlert = false
    
    /// Initial blur value for input fields to be animated away.
    @State private var inputBlur: CGFloat = 10
    /// Initial blur value for the button to be animated away.
    @State private var buttonBlur: CGFloat = 10

    // MARK: - Validation
    
    /// Validates that the goal weight and daily calorie goal are greater than zero.
    var isStep3Valid: Bool {
        viewModel.goalWeight > 0 && viewModel.dailyCalorieGoal > 0
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // MARK: Animated Prompt & Input Fields Section
                // Display an animated typewriter text prompt.
                TypewriterText(fullText: "Let's set your goals clear. Elevate your potential.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        // Reveal the input fields immediately after the animation.
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent = true
                            }
                        }
                        // Reveal the Finish button with a slight delay.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent1 = true
                            }
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                // Conditionally show the input fields once the animation is complete.
                if showContent {
                    VStack(spacing: 20) {
                        // Input field for setting the weight goal (Double value).
                        OnboardingInputCellDouble(
                            title: "Weight Goal",
                            placeholder: "....",
                            systemImageName: "target",
                            value: $viewModel.goalWeight
                        )
                        // Input field for setting the daily calorie goal (Int value).
                        OnboardingInputCellInt(
                            title: "Calories Goal",
                            placeholder: "....",
                            systemImageName: "flame.fill",
                            value: $viewModel.dailyCalorieGoal
                        )
                        // Input field for setting the daily steps goal (Int value).
                        OnboardingInputCellInt(
                            title: "Steps Goal",
                            placeholder: "....",
                            systemImageName: "figure.walk",
                            value: $viewModel.dailyStepsGoal
                        )
                        // Input field for setting the daily burned calories goal (Int value).
                        OnboardingInputCellInt(
                            title: "Calories Burned",
                            placeholder: "....",
                            systemImageName: "flame",
                            value: $viewModel.dailyBurnedCaloriesGoal
                        )
                    }
                    .transition(.opacity) // Fade in the input fields.
                    .blur(radius: inputBlur) // Apply an initial blur.
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            inputBlur = 0
                            // Set the starting weight equal to the current weight.
                            viewModel.startWeight = viewModel.currentWeight
                        }
                    }
                }
                
                Spacer()
                
                // MARK: Finish Button
                if showContent1 {
                    Button(action: {
                        // Validate that required fields are filled.
                        if isStep3Valid {
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            // Complete onboarding by updating persistent storage.
                            hasCompletedOnboarding = true
                        } else {
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            // Show a custom alert if validation fails.
                            withAnimation {
                                showCustomAlert = true
                            }
                        }
                    }) {
                        Text("Finish")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .transition(.opacity) // Fade in the button.
                    .blur(radius: buttonBlur) // Apply an initial blur.
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            buttonBlur = 0
                        }
                    }
                }
                
                Spacer()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            // Dismiss the keyboard when tapping outside the input fields.
            .onTapGesture { UIApplication.shared.endEditing() }
            // Blur the main content if the custom alert is visible.
            .blur(radius: showCustomAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: showCustomAlert)
            
            // MARK: Custom Alert Overlay
            if showCustomAlert {
                // Semi-transparent overlay to dim the background.
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showCustomAlert = false
                        }
                    }
                // Custom alert view displaying the error message.
                CustomAlert(
                    title: "Incomplete Details",
                    message: "Please fill in your starting weight, goal weight, and daily calorie goal to continue."
                ) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCustomAlert = false
                    }
                }
                .transition(.blurScale) // Apply a custom transition for the alert.
                .zIndex(1) // Ensure the alert is displayed on top.
            }
        }
    }
}

struct OnboardingStep3View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let context = PersistenceController.preview.container.viewContext
            let viewModel = UserProfileViewModel(context: context)
            OnboardingStep3View(viewModel: viewModel)
        }
    }
}

import SwiftUI

/// The second step of the onboarding process where the user provides physical details.
/// This view displays an animated typewriter text prompt, input fields for height and weight,
/// and a "Next" button that navigates to the next onboarding step if validation passes.
/// A custom alert is presented when required fields are incomplete.
struct OnboardingStep2View: View {
    // MARK: - Observed Objects
    
    /// The view model holding user profile data.
    @ObservedObject var viewModel: UserProfileViewModel

    // MARK: - Environment
    
    /// Access the current color scheme (light or dark) for dynamic styling.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Local State
    
    /// Controls the visibility of the animated content (input fields).
    @State private var showContent = false
    /// Controls the visibility of the "Next" button.
    @State private var showContent1 = false
    /// Triggers navigation to the next onboarding step.
    @State private var navigateToStep3 = false
    /// Controls the display of a custom alert when input validation fails.
    @State private var showCustomAlert = false
    /// Offset for the typewriter text, allowing potential adjustments.
    @State private var textOffset: CGFloat = 0
    /// Blur amount applied to the input fields during animation.
    @State private var inputBlur: CGFloat = 10
    /// Blur amount applied to the button during animation.
    @State private var buttonBlur: CGFloat = 10

    // Local staging state for onboarding inputs
    @State private var stagingHeight: Int = 0
    @State private var stagingWeight: Double = 0

    // MARK: - Validation
    
    /// Ensures that both height and current weight are greater than 0.
    var isStep2Valid: Bool {
        stagingHeight > 0 && stagingWeight > 0
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Initialize staging from view model
            VStack {
                Spacer()
                
                // MARK: Animated Typewriter Text & Input Fields
                VStack(spacing: 20) {
                    // Display animated typewriter text that provides the prompt.
                    TypewriterText(fullText: "Define your physical essence. Every detail matters.", interval: 0.04) {
                        // Once animation completes, reveal the input fields and button with delays.
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent1 = true
                            }
                        }
                    }
                    // Apply any offset adjustments to the text if needed.
                    .offset(y: textOffset)
                    
                    // Conditionally display the input fields with a fade-in effect.
                    if showContent {
                        VStack(spacing: 20) {
                            // Input cell for the user's height.
                            OnboardingInputCellInt(
                                title: "Height (cm)",
                                placeholder: "....",
                                systemImageName: "ruler.fill",
                                value: $stagingHeight
                            )
                            // Input cell for the user's weight.
                            OnboardingInputCellDouble(
                                title: "Weight (kg)",
                                placeholder: "....",
                                systemImageName: "scalemass",
                                value: $stagingWeight
                            )
                        }
                        .transition(.opacity) // Fade in the input fields.
                        .blur(radius: inputBlur) // Start with a blur that animates out.
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0)) {
                                inputBlur = 0
                            }
                        }
                    } else {
                        // Placeholder space if inputs are not shown yet.
                        Color.clear.frame(height: 150)
                    }
                }
                
                Spacer()
                
                // MARK: Next Button
                if showContent1 {
                    Button(action: {
                        // Validate input fields.
                        if isStep2Valid {
                            // Haptic feedback for success.
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            viewModel.height = stagingHeight
                            viewModel.currentWeight = stagingWeight
                            viewModel.startWeight = stagingWeight
                            // Trigger navigation to Step 3.
                            navigateToStep3 = true
                        } else {
                            // Haptic feedback for error.
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            // Animate the display of a custom alert.
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
                    .disabled(!isStep2Valid)
                    .opacity(isStep2Valid ? 1 : 0.5)
                    .transition(.opacity) // Fade in the button.
                    .blur(radius: buttonBlur) // Start with a blur that animates out.
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            buttonBlur = 0
                        }
                    }
                }
                
                Spacer()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            // Dismiss the keyboard when tapping outside of input fields.
            .onTapGesture { UIApplication.shared.endEditing() }
            // Apply blur to the main content when the custom alert is active.
            .blur(radius: showCustomAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: showCustomAlert)
            
            // MARK: Custom Alert Overlay
            if showCustomAlert {
                // Semi-transparent background overlay that dims the content.
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showCustomAlert = false
                        }
                    }
                // Custom alert view displaying the validation error message.
                CustomAlert(
                    title: "Incomplete Details",
                    message: "Please fill in your height and weight to continue."
                ) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCustomAlert = false
                    }
                }
                .transition(.blurScale) // Use a custom transition for the alert.
                .zIndex(1) // Ensure the alert appears above all other content.
            }
        }
        .onAppear {
            stagingHeight = viewModel.height
            stagingWeight = viewModel.currentWeight
        }
        // MARK: Navigation to Next Step
        .navigationDestination(isPresented: $navigateToStep3) {
            OnboardingStep3View(viewModel: viewModel)
        }
    }
}

struct OnboardingStep2View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let context = PersistenceController.preview.container.viewContext
            let viewModel = UserProfileViewModel(context: context)
            OnboardingStep2View(viewModel: viewModel)
        }
    }
}

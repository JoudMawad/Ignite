import SwiftUI

struct OnboardingStep3View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false       // For input fields
    @State private var showContent1 = false      // For the button
    @State private var hasCompletedAnimation = false
    @State private var showCustomAlert = false
    @State private var inputBlur: CGFloat = 10
    @State private var buttonBlur: CGFloat = 10

    var isStep3Valid: Bool {
        return
               viewModel.goalWeight > 0 &&
               viewModel.dailyCalorieGoal > 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // Animated title with typewriter effect.
                TypewriterText(fullText: "Let's set your goals clear. Elevate your potential.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        // Show input fields after a 1-second delay.
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent = true
                            }
                        }
                        // Show the button after an additional 0.8 seconds.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                showContent1 = true
                            }
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                if showContent {
                    VStack(spacing: 20) {
                        OnboardingInputCellDouble(
                            title: "Weight Goal",
                            placeholder: "....",
                            systemImageName: "target",
                            value: $viewModel.goalWeight
                        )
                        OnboardingInputCellInt(
                            title: "Calories Goal",
                            placeholder: "....",
                            systemImageName: "flame.fill",
                            value: $viewModel.dailyCalorieGoal
                        )
                        OnboardingInputCellInt(
                            title: "Steps Goal",
                            placeholder: "....",
                            systemImageName: "figure.walk",
                            value: $viewModel.dailyStepsGoal
                        )
                        OnboardingInputCellInt(
                            title: "Calories Burned",
                            placeholder: "....",
                            systemImageName: "flame",
                            value: $viewModel.dailyBurnedCaloriesGoal
                        )
                    }
                    .transition(.opacity)
                    .blur(radius: inputBlur)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            inputBlur = 0
                        }
                    }
                }
                
                Spacer()
                
                if showContent1 {
                    Button(action: {
                        if isStep3Valid {
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            hasCompletedOnboarding = true
                        } else {
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            withAnimation {
                                showCustomAlert = true
                            }
                        }
                    }) {
                        Text("Finish")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
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
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
            // Custom alert overlay for validation errors.
            if showCustomAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                CustomAlert(
                    title: "Incomplete Details",
                    message: "Please fill in your starting weight, goal weight, and daily calorie goal to continue."
                ) {
                    withAnimation {
                        showCustomAlert = false
                    }
                }
                .transition(.scale)
                .zIndex(1)
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

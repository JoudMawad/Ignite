import SwiftUI

struct OnboardingStep3View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    @State private var hasCompletedAnimation = false
    @State private var showCustomAlert = false
    
    var isStep3Valid: Bool {
        return viewModel.startWeight > 0 &&
               viewModel.goalWeight > 0 &&
               viewModel.dailyCalorieGoal > 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                TypewriterText(fullText: "Let's set your goals clear. Elevate your potential.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        withAnimation(.easeOut(duration: 1.0)) {
                            showContent = true
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                if showContent {
                    VStack(spacing: 20) {
                        OnboardingInputCellDouble(
                            title: "Weight",
                            placeholder: "....",
                            systemImageName: "scalemass",
                            value: $viewModel.startWeight
                        )
                        
                        OnboardingInputCellDouble(
                            title: "Goal",
                            placeholder: "....",
                            systemImageName: "target",
                            value: $viewModel.goalWeight
                        )
                        
                        OnboardingInputCellInt(
                            title: "Calories",
                            placeholder: "....",
                            systemImageName: "flame.fill",
                            value: $viewModel.dailyCalorieGoal
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 1.0), value: showContent)
                }
                
                Spacer()
                
                if showContent {
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
                }
                
                Spacer()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
            // Custom alert overlay when validation fails.
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
        let context = PersistenceController.preview.container.viewContext
        let viewModel = UserProfileViewModel(context: context)
        NavigationView {
            OnboardingStep3View(viewModel: viewModel)
        }
    }
}

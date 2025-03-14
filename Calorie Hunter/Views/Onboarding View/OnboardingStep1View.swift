import SwiftUI

struct OnboardingStep1View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    @State private var hasCompletedAnimation = false
    @State private var navigateToStep2 = false
    @State private var showCustomAlert = false

    // Validation: Name and Gender must not be empty, and Age must be greater than 0.
    var isStep1Valid: Bool {
        return !viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !viewModel.gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               viewModel.age > 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // Animated title
                TypewriterText(fullText: "Welcome. Let's build your profile.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        withAnimation(.easeOut(duration: 1.0)) {
                            showContent = true
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                if showContent {
                    VStack(spacing: 20) {
                        OnboardingInputCellString(
                            title: "Name",
                            placeholder: "....",
                            systemImageName: "person.fill",
                            value: $viewModel.name
                        )
                        
                        OnboardingInputCellPicker(
                            title: "Gender",
                            systemImageName: "person.2.fill",
                            options: ["Male", "Female", "Other"],
                            selection: $viewModel.gender
                        )
                        
                        OnboardingInputCellInt(
                            title: "Age",
                            placeholder: "....",
                            systemImageName: "number.circle",
                            value: $viewModel.age
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 1.0), value: showContent)
                }
                
                Spacer()
                
                if showContent {
                    Button(action: {
                        if isStep1Valid {
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            navigateToStep2 = true
                        } else {
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            withAnimation {
                                showCustomAlert = true
                            }
                        }
                    }) {
                        Text("Next")
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
                    message: "It looks like some fields are missing. Please fill in your name, gender, and age to proceed."
                ) {
                    withAnimation {
                        showCustomAlert = false
                    }
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        // Use the new navigationDestination modifier.
        .navigationDestination(isPresented: $navigateToStep2) {
            OnboardingStep2View(viewModel: viewModel)
        }
    }
}

struct OnboardingStep1View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { // Use NavigationStack for iOS 16+
            let context = PersistenceController.preview.container.viewContext
            let viewModel = UserProfileViewModel(context: context)
            OnboardingStep1View(viewModel: viewModel)
        }
    }
}

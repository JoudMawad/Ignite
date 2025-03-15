import SwiftUI

struct OnboardingStep2View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    @State private var hasCompletedAnimation = false
    @State private var navigateToStep3 = false
    @State private var showCustomAlert = false

    var isStep2Valid: Bool {
        return viewModel.height > 0 && viewModel.currentWeight > 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                TypewriterText(fullText: "Define your physical essence. Every detail matters.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        withAnimation(.easeOut(duration: 1.0)) {
                            showContent = true
                        }
                        hasCompletedAnimation = true
                    }
                }
                
                if showContent {
                    VStack(spacing: 20) {
                        OnboardingInputCellInt(
                            title: "Height (cm)",
                            placeholder: "....",
                            systemImageName: "ruler.fill",
                            value: $viewModel.height
                        )
                        
                        OnboardingInputCellDouble(
                            title: "Weight (kg)",
                            placeholder: "....",
                            systemImageName: "scalemass",
                            value: $viewModel.currentWeight
                        )
                        .onChange(of: viewModel.currentWeight) { newValue, _ in
                            viewModel.startWeight = newValue
                        }

                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 1.0), value: showContent)
                }
                
                Spacer()
                
                if showContent {
                    Button(action: {
                        if isStep2Valid {
                            let successFeedback = UINotificationFeedbackGenerator()
                            successFeedback.notificationOccurred(.success)
                            navigateToStep3 = true
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
            
            // Custom alert overlay.
            if showCustomAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                CustomAlert(
                    title: "Incomplete Details",
                    message: "Please fill in your height and weight to continue."
                ) {
                    withAnimation {
                        showCustomAlert = false
                    }
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        // New navigation API.
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

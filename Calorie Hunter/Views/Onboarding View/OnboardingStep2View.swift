import SwiftUI

struct OnboardingStep2View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    @State private var showContent1 = false
    @State private var navigateToStep3 = false
    @State private var showCustomAlert = false
    @State private var textOffset: CGFloat = 0
    @State private var inputBlur: CGFloat = 10
    @State private var buttonBlur: CGFloat = 10

    var isStep2Valid: Bool {
        viewModel.height > 0 && viewModel.currentWeight > 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    TypewriterText(fullText: "Define your physical essence. Every detail matters.", interval: 0.04) {
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
                    .offset(y: textOffset)
                    
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
                        .transition(.opacity)
                        .blur(radius: inputBlur)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0)) {
                                inputBlur = 0
                            }
                        }
                    } else {
                        Color.clear.frame(height: 150)
                    }
                }
                
                Spacer()
                
                if showContent1 {
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
            .onTapGesture { UIApplication.shared.endEditing() }
            // Blur the main content when the alert is active.
            .blur(radius: showCustomAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: showCustomAlert)
            
            // Alert overlay identical to Step 1.
            if showCustomAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showCustomAlert = false
                        }
                    }
                CustomAlert(
                    title: "Incomplete Details",
                    message: "Please fill in your height and weight to continue."
                ) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCustomAlert = false
                    }
                }
                .transition(.blurScale)
                .zIndex(1)
            }
        }
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

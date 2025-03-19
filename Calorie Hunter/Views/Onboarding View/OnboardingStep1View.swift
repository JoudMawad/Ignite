import SwiftUI

// MARK: - OnboardingStep1View

struct OnboardingStep1View: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false       // For input fields
    @State private var showContent1 = false        // For the button
    @State private var hasCompletedAnimation = false
    @State private var navigateToStep2 = false
    @State private var showCustomAlert = false
    
    @StateObject var imageVM = ProfileImageViewModel()
    @State private var isShowingImagePicker = false

    @State private var inputBlur: CGFloat = 10
    @State private var buttonBlur: CGFloat = 10

    // Validation: Name, Gender must not be empty, and Age must be greater than 0.
    var isStep1Valid: Bool {
        return !viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !viewModel.gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               viewModel.age > 0
    }
    
    var body: some View {
        ZStack {
            // Main content with conditional blur.
            VStack {
                Spacer()
                
                // Animated title with typewriter effect.
                TypewriterText(fullText: "Welcome. Let's build your profile.", interval: 0.04) {
                    if !hasCompletedAnimation {
                        // Show input fields after a short delay.
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
                        OnboardingProfilePicCell(
                                                    isShowingImagePicker: $isShowingImagePicker,
                                                    profileImage: $imageVM.profileImage
                                                )
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
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .blur(radius: showCustomAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: showCustomAlert)
            
            // Custom Alert Overlay.
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
                    message: "It looks like some fields are missing. Please fill in your name, gender, and age to proceed."
                ) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCustomAlert = false
                    }
                }
                .transition(.blurScale)
                .zIndex(1)
            }
        }
        // Navigation to Step 2.
        .navigationDestination(isPresented: $navigateToStep2) {
            OnboardingStep2View(viewModel: viewModel)
        }
        // **Attach the sheet modifier here**
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $imageVM.profileImage)
        }
    }
}


struct OnboardingStep1View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { // Using NavigationStack for iOS 16+
            let context = PersistenceController.preview.container.viewContext
            let viewModel = UserProfileViewModel(context: context)
            OnboardingStep1View(viewModel: viewModel)
        }
    }
}

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

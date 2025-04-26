import SwiftUI
import HealthKit

@main
struct Calorie_HunterApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()
    @StateObject var userProfileVM = UserProfileViewModel()
    
    // Control the display of the splash screen
    @State private var showSplash = true

    init() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                HealthKitManager.shared.enableBackgroundDeliveryForAll()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main SwiftUI content.
                ContentView()
                    .environmentObject(burnedCaloriesViewModel)
                    .environmentObject(userProfileVM)
                    .fullScreenCover(isPresented: Binding(
                        get: { !hasCompletedOnboarding },
                        set: { _ in }
                    )) {
                        NavigationStack {
                            OnboardingStep1View(viewModel: UserProfileViewModel())
                        }
                    }
                
                // Splash view overlay – only visible when showSplash is true.
                if showSplash {
                    SplashView()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Delay the removal of the splash screen to let the animation play
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }
}

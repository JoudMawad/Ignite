import SwiftUI
import HealthKit

@main
struct Calorie_HunterApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()
    
    // Control the display of the splash screen
    @State private var showSplash = true

    init() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("✅ HealthKit authorization successful in App initializer.")
                HealthKitManager.shared.enableBackgroundDeliveryForAll()
            } else {
                print("❌ HealthKit authorization failed in App initializer: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main SwiftUI content.
                ContentView()
                    .environmentObject(burnedCaloriesViewModel)
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
                print("Calorie_HunterApp: onAppear")
                // Delay the removal of the splash screen to let the animation play
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                    withAnimation {
                        print("Hiding splash view")
                        showSplash = false
                    }
                }
            }
        }
    }
}

import SwiftUI
import HealthKit

@main
struct Calorie_HunterApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()

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
            ContentView()
                .environmentObject(burnedCaloriesViewModel)
                .fullScreenCover(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { _ in }
                )) {
                    NavigationStack {  // Use NavigationStack instead of NavigationView
                        OnboardingStep1View(viewModel: UserProfileViewModel())
                    }
                }
        }
    }
}

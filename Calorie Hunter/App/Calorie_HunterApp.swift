import SwiftUI
import HealthKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Request HealthKit authorization before any UI is shown
        guard HKHealthStore.isHealthDataAvailable() else { return true }
        HealthKitManager.shared.requestAuthorization { success, _ in
            if success {
                HealthKitManager.shared.enableBackgroundDeliveryForAll()
            }
        }
        return true
    }
}

@main
struct Calorie_HunterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()
    @StateObject var userProfileVM = UserProfileViewModel()
    @StateObject var goalsViewModel = GoalsViewModel()
    @StateObject private var foodViewModel = FoodViewModel(
        context: PersistenceController.shared.container.viewContext
    )
    @Environment(\.scenePhase) private var scenePhase
    
    // Control the display of the splash screen
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main SwiftUI content.
                ContentView()
                    .environmentObject(burnedCaloriesViewModel)
                    .environmentObject(userProfileVM)
                    .environmentObject(goalsViewModel)
                    .environmentObject(foodViewModel)
                    .fullScreenCover(isPresented: Binding(
                        get: { !hasCompletedOnboarding },
                        set: { _ in }
                    )) {
                        NavigationStack {
                            OnboardingStep1View(viewModel: userProfileVM, goalsViewModel: goalsViewModel)
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                foodViewModel.loadEntries()
            }
        }
    }
}

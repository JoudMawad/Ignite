import SwiftUI
import HealthKit

@main
struct Calorie_HunterApp: App {
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()

    init() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("✅ HealthKit authorization successful in App initializer.")
                HealthKitManager.shared.enableBackgroundDeliveryForAll()
                // Instead of creating a new view model, post a notification that the app is ready.
            } else {
                print("❌ HealthKit authorization failed in App initializer: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(burnedCaloriesViewModel)
        }
    }
}

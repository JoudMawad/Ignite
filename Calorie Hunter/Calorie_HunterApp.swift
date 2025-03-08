import SwiftUI

@main
struct Calorie_HunterApp: App {
    init() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("✅ HealthKit authorization successful in App initializer.")
            } else {
                print("❌ HealthKit authorization failed in App initializer: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

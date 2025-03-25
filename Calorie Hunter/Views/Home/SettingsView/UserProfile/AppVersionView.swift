import SwiftUI

struct AppVersionView: View {
    // Retrieve the app version from the main bundle's info dictionary.
    // If not found, default to "Unknown".
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    // Retrieve the build number from the main bundle's info dictionary.
    // If not found, default to "Unknown".
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        // Display the version and build number in a small, gray font.
        Text("Version \(appVersion) (Build \(buildNumber))")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding()
    }
}

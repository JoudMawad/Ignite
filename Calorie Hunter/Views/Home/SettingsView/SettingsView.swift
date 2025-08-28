import SwiftUI

/// A settings view that hosts a tab view with a user profile and pre-defined food storage screens.
/// It dynamically updates the UITabBar appearance based on the current color scheme.
struct SettingsView: View {
    // MARK: - Properties
    
    /// The view model for managing the user profile data.
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()
    
    /// Provides the current color scheme (light or dark) for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Helper Methods
    
    /// Updates the appearance of the UITabBar to match the current color scheme.
    /// - Parameter scheme: The current color scheme.
    private func updateTabBarAppearance(for scheme: ColorScheme) {
        // Create a new UITabBarAppearance instance.
        let appearance = UITabBarAppearance()
        // Configure the appearance with an opaque background.
        appearance.configureWithOpaqueBackground()
        // Set the background color based on the color scheme.
        appearance.backgroundColor = (scheme == .dark) ? .black : .white
        // Remove the default separator by clearing the shadow and background images.
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        
        // Apply the custom appearance to the UITabBar.
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // TabView that holds different settings screens.
            TabView {
                // First tab for the user profile screen.
                UserProfileView(viewModel: userProfileViewModel, goalsViewModel: goalsViewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                
                // Second tab for a view that displays pre-defined foods.
                UserPreDefinedFoodsView()
                    .tabItem {
                        Label("Food Storage", systemImage: "list.bullet")
                    }
            }
            // Extend the background color to cover the entire screen area.
            .background(Color.primary.edgesIgnoringSafeArea(.all))
            // Tint the tab items with the primary color.
            .tint(.primary)
            // When the view appears, update the tab bar appearance.
            .onAppear {
                updateTabBarAppearance(for: colorScheme)
            }
            // Listen for changes in the color scheme and update the tab bar accordingly.
            .onChange(of: colorScheme) { newScheme, _ in
                updateTabBarAppearance(for: newScheme)
            }
        }
    }
}

// MARK: - Preview

/// Provides a live preview of the SettingsView in Xcode.
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

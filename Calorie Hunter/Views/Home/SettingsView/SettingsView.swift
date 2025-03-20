import SwiftUI

struct SettingsView: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Update UITabBar appearance based on current color scheme
    private func updateTabBarAppearance(for scheme: ColorScheme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = (scheme == .dark) ? .black : .white
        // Removes the thin grey line (tab bar separator)
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            TabView {
                UserProfileView(viewModel: userProfileViewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                
                UserPreDefinedFoodsView()
                    .tabItem {
                        Label("Food Storage", systemImage: "list.bullet")
                    }
            }
            .background(Color.primary.edgesIgnoringSafeArea(.all))
            .tint(.primary)
            .onAppear {
                updateTabBarAppearance(for: colorScheme)
            }
            .onChange(of: colorScheme) { newScheme, _ in
                updateTabBarAppearance(for: newScheme)
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

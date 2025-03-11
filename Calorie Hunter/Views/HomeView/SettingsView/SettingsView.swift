import SwiftUI

struct SettingsView: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
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
            .background(colorScheme == .dark ? Color.black : Color.white) //Black background
            .toolbarBackground(colorScheme == .dark ? Color.black : Color.white) //Black toolbar
            .tint(colorScheme == .dark ? Color.white : Color.black) //White tint for tab bar
        }
        .background(colorScheme == .dark ? Color.black : Color.white) //Ensures background is fully black
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

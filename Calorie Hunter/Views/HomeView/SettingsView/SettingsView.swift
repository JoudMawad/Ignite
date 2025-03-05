import SwiftUI

struct SettingsView: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()

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
            .background(Color.black.edgesIgnoringSafeArea(.all)) //Black background
            .toolbarBackground(Color.black, for: .automatic) //Black toolbar
            .tint(.white) //White tint for tab bar
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) //Ensures background is fully black
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

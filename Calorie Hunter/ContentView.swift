import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = FoodViewModel()
    @StateObject var userProfileViewModel = UserProfileViewModel()
    
    init() {
        // Fully remove the default tab bar shadow and blur
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
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
                // Home Page
                HomeView(viewModel: viewModel, userProfileViewModel: userProfileViewModel)
                    .tabItem {
                        Label("", systemImage: "house.fill")
                    }

                // Charts Page
                ChartsView(foodViewModel: FoodViewModel(), userProfileViewModel: UserProfileViewModel())
                    .tabItem {
                        Label("", systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
            .background(Color.primary.edgesIgnoringSafeArea(.all)) // Ensures no white separator
            .tint(.primary
               ) // Ensures tab icons/text stay visible
        }
    }
}

#Preview {
    ContentView()
}

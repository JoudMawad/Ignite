import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = FoodViewModel()
    @StateObject var userProfileViewModel = UserProfileViewModel()
    
    init() {
        // Fully remove the default tab bar shadow and blur
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Removes the thin grey line (tab bar separator)
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Ensures background is black

            TabView {
                // Home Page
                HomeView(viewModel: viewModel, userProfileViewModel: userProfileViewModel)
                    .tabItem {
                        Label("", systemImage: "house.fill")
                    }

                // Charts Page
                ChartsView(viewModel: viewModel)
                    .tabItem {
                        Label("", systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Ensures no white separator
            .tint(.white) // Ensures tab icons/text stay visible
        }
    }
}

#Preview {
    ContentView()
}

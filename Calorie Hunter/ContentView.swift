import SwiftUI
import CoreData
import UIKit

/// The main container view of the app that houses the tab view.
/// This view sets up the necessary view models and customizes the tab bar appearance.
struct ContentView: View {
    @StateObject var viewModel: FoodViewModel
    @StateObject var stepsviewModel = StepsViewModel()
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var goalsViewModel: GoalsViewModel
    @State private var selectedTab: Int = 0
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)

    init() {
        let pc = PersistenceController.shared
        _viewModel = StateObject(wrappedValue: FoodViewModel(context: pc.container.viewContext))

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                viewModel: viewModel,
                stepsViewModel: stepsviewModel,
                burnedCaloriesViewModel: burnedCaloriesViewModel,
                goalsViewModel: goalsViewModel,
                userProfileViewModel: userProfileViewModel
            )
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .tabItem { Label("", systemImage: "house.fill") }
            .tag(0)

            ChartsView(
                foodViewModel: viewModel,
                userProfileViewModel: userProfileViewModel
            )
            .tabItem { Label("", systemImage: "chart.line.uptrend.xyaxis") }
            .tag(1)
        }
        .background(Color.primary.edgesIgnoringSafeArea(.all))
        .tint(.primary)
        .onChange(of: selectedTab) { tapFeedback.impactOccurred() }
    }
}

#Preview {
    ContentView()
}

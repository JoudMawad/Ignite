import SwiftUI
import CoreData
import UIKit

/// The main container view of the app that houses the tab view.
/// This view sets up the necessary view models and customizes the tab bar appearance.
struct ContentView: View {
    // MARK: - State Objects
    
    /// View model managing food-related data.
    @StateObject var viewModel: FoodViewModel
    /// View model tracking steps.
    @StateObject var stepsviewModel = StepsViewModel()
    /// View model tracking burned calories.
    @StateObject var burnedCaloriesViewModel = BurnedCaloriesViewModel()
    /// View model containing user profile information.
    @StateObject var userProfileViewModel = UserProfileViewModel()
    
    /// Tracks the selected tab index for haptic feedback.
    @State private var selectedTab: Int = 0
    /// Light tap haptic feedback generator for tab taps.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Initialization
    
    init() {
        // Initialize the food view model with Core Data context
        let pc = PersistenceController.shared
        _viewModel = StateObject(wrappedValue: FoodViewModel(context: pc.container.viewContext))
        
        // Configure the UITabBarAppearance to remove the default shadow and blur.
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Use the system background color to blend with the app's overall theme.
        appearance.backgroundColor = UIColor.systemBackground
        
        // Remove the thin grey line (tab bar separator) by clearing the shadow and background images.
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        
        // Apply the custom appearance to the tab bar.
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main TabView that switches between the Home and Charts pages.
            TabView(selection: $selectedTab) {
                // MARK: Home Page
                HomeView(
                    viewModel: viewModel,
                    stepsViewModel: stepsviewModel,
                    burnedCaloriesViewModel: burnedCaloriesViewModel,
                    userProfileViewModel: userProfileViewModel
                )
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .tabItem {
                    Label("", systemImage: "house.fill")
                }
                .tag(0)
                
                // MARK: Charts Page
                ChartsView(
                    foodViewModel: viewModel,
                    userProfileViewModel: userProfileViewModel
                )
                .tabItem {
                    Label("", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            }
            // Extend the background color to the edges to prevent any unwanted white separators.
            .background(Color.primary.edgesIgnoringSafeArea(.all))
            // Tint the tab icons and text to ensure visibility across color schemes.
            .tint(.primary)
            .onChange(of: selectedTab) {
                tapFeedback.impactOccurred()
            }
        }
    }
}

#Preview {
    ContentView()
}

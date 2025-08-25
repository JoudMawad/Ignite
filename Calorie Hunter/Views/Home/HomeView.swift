import SwiftUI
import UIKit
import CoreData

/// The main home view that presents the user's dashboard, including welcome text, charts,
/// steps and burned calories cards, water intake, a food list, and a calendar view.
/// It also includes a settings button in the navigation bar.
struct HomeView: View {
    // MARK: - Observed Objects
    
    /// The view model handling food-related data.
    @ObservedObject var viewModel: FoodViewModel
    
    /// The view model managing the user's step count.
    @ObservedObject var stepsViewModel: StepsViewModel
    
    /// The view model that tracks burned calories.
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    
    /// The view model providing user profile information.
    @ObservedObject var userProfileViewModel: UserProfileViewModel

    // MARK: - Environment
    
    /// Accesses the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme

    @Environment(\.managedObjectContext) private var context

    // MARK: - Local State Objects
    
    /// Instantiates the WaterViewModel locally using the shared persistence container.
    @StateObject private var waterViewModel = WaterViewModel(container: PersistenceController.shared.container)
    
    /// Tracks whether the settings view should be presented.
    @State private var showSettings = false
    @State private var selectedDate: Date? = nil
    
    /// Haptic feedback for toolbar button taps.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)
    
    /// ViewModel for tracking exercises.
    @StateObject private var exerciseViewModel = ExerciseViewModel()

    // MARK: - Initialization
    
    /// Custom initializer to configure view models and the navigation bar appearance.
    init(viewModel: FoodViewModel,
         stepsViewModel: StepsViewModel,
         burnedCaloriesViewModel: BurnedCaloriesViewModel,
         userProfileViewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        self.stepsViewModel = stepsViewModel
        self.burnedCaloriesViewModel = burnedCaloriesViewModel
        self.userProfileViewModel = userProfileViewModel

        // Configure transparent navigation bar appearance.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Welcome Section
                    welcomeSection
                    
                    // MARK: - Charts & Activity Cards Section
                    HStack(alignment: .top, spacing: 11) {
                        chartsCardSection
                        VStack {
                            // Displays a card with step count information.
                            StepsCardView(viewModel: userProfileViewModel, stepsViewModel: stepsViewModel)
                            // Displays a card with burned calories information.
                            BurnedCaloriesCardView(burnedCaloriesviewModel: burnedCaloriesViewModel, viewModel: userProfileViewModel)
                        }
                    }
                    
                    // MARK: - Water Intake Section
                    waterSection
                    
                    // MARK: - Food List Section
                    foodListSection
                    
                    // MARK: - Exercise Card Section
                    ExerciseCardView(viewModel: exerciseViewModel)
                        .task {
                            exerciseViewModel.startHealthKitSync()
                        }
                    
                    // MARK: - Calendar Section
                    CalendarView(
                        selectedDate: $selectedDate,
                        userProfileViewModel: userProfileViewModel,
                        stepsViewModel: stepsViewModel,
                        burnedCaloriesViewModel: burnedCaloriesViewModel,
                        waterViewModel: waterViewModel
                    )
                    .id("CalendarCard")
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
                .onChange(of: selectedDate) { _, new in
                    if new == nil {
                        withAnimation {
                            proxy.scrollTo("CalendarCard", anchor: .top)
                        }
                    }
                }
            }
            .toolbar {
                // Toolbar item for the settings gear button.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        tapFeedback.impactOccurred()
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            // Present the settings view modally when showSettings is true.
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - View Components
    
    /// The welcome section that greets the user by name.
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            TypingText(fullText: "Welcome, \(userProfileViewModel.firstName).")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// The charts card section which includes charts and a header message.
    private var chartsCardSection: some View {
        ZStack {
            // Background card with rounded corners and shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 5, x: 0, y: 4)
            
            GeometryReader { geometry in
                // Calculate header height based on available geometry.
                let headerHeight = geometry.size.height * (0.5 / 3)
                
                VStack(spacing: 0) {
                    // Header text above the charts.
                    HStack {
                        Text("Keep a close eye on these.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    // TabView for switching between different chart views.
                    TabView {
                        CalorieChartView(
                            viewModel: userProfileViewModel,
                            totalCalories: viewModel.totalCalories,
                            burnedCalories: Int(burnedCaloriesViewModel.currentBurnedCalories)
                        )
                        .padding(6)
                        .padding(.horizontal, 8)
                        
                        FoodChartView(
                            totalProtein: viewModel.totalProtein,
                            totalCarbs: viewModel.totalCarbs,
                            totalFat: viewModel.totalFat
                        )
                        .padding(8)
                        .padding(.vertical, 8)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(width: geometry.size.width, height: geometry.size.height - headerHeight)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
    
    /// The water intake section, showing daily water progress.
private var waterSection: some View {
    WaterProgressView(
        waterViewModel: waterViewModel,
        profileViewModel: userProfileViewModel
    )
}
    
    /// The food list section that displays a list of foods and provides an action to add more food.
    private var foodListSection: some View {
        FoodListView(viewModel: viewModel, addFoodAction: { mealType in
            openAddFoodView(for: mealType)
        })
    }
    
    // MARK: - Helper Methods
    
    /// Presents the AddFoodView modally for a specific meal type.
    /// - Parameter mealType: The type of meal (e.g., breakfast, lunch) for which to add food.
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
                .environment(\.managedObjectContext, context)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

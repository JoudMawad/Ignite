import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FoodViewModel
    @ObservedObject var stepsviewModel: StepsViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme

    // Instantiate WaterViewModel locally.
    @StateObject private var waterViewModel = WaterViewModel(container: PersistenceController.shared.container)
    
    @State private var showSettings = false
    
    init(viewModel: FoodViewModel, stepsviewModel: StepsViewModel, burnedCaloriesViewModel: BurnedCaloriesViewModel, userProfileViewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        self.stepsviewModel = stepsviewModel
        self.burnedCaloriesViewModel = burnedCaloriesViewModel
        self.userProfileViewModel = userProfileViewModel
        
        // Configure navigation bar appearance to be transparent with no shadow.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()  // Makes background transparent.
        appearance.shadowColor = .clear                // Removes the line.
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Welcome Section
                    welcomeSection
                    
                    // MARK: - Charts & Water Intake Section
                    HStack(alignment: .top, spacing: 11) {
                        // This is the card that contains the header text and charts.
                        chartsCardSection
                        VStack{
                            StepsCardView(stepsViewModel: stepsviewModel)
                            
                            BurnedCaloriesCardView(viewModel: burnedCaloriesViewModel)
                        }
                    }
                    // Water Intake View placed to the right.
                    waterSection
                    
                    // MARK: - Food List Section
                    foodListSection
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            TypingText(fullText: "Welcome, \(userProfileViewModel.firstName)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Charts Card Section
    private var chartsCardSection: some View {
        ZStack {
            // Background Card
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 5, x: 0, y: 4)
            
            GeometryReader { geometry in
                let headerHeight = geometry.size.height * (0.5 / 3)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Keep a close eye on these.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    TabView {
                        CalorieChartView(
                            viewModel: userProfileViewModel,
                            totalCalories: viewModel.totalCalories
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
    
    // MARK: - Water Intake Section
    private var waterSection: some View {
        WaterProgressView(waterViewModel: waterViewModel, dailyGoal: 2.8)
    }
    
    // MARK: - Food List Section
    private var foodListSection: some View {
        FoodListView(viewModel: viewModel, addFoodAction: { mealType in
            openAddFoodView(for: mealType)
        })
    }
    
    // MARK: - Helper Method
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

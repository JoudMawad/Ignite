import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FoodViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    
    // Instantiate WaterViewModel locally (adjust the container as needed)
    @StateObject private var waterViewModel = WaterViewModel(container: PersistenceController.shared.container)
    
    @State private var showSettings = false
    
    // Computed property for today's date string.
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium    // e.g. "Mar 10, 2025"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Sliding Charts Section
                    TabView {
                        CalorieChartView(
                            viewModel: userProfileViewModel,
                            totalCalories: viewModel.totalCalories
                        )
                        
                        FoodChartView(
                            totalProtein: viewModel.totalProtein,
                            totalCarbs: viewModel.totalCarbs,
                            totalFat: viewModel.totalFat
                        )
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 330)
                    .padding(.top, 10)
                    
                    
                    WaterProgressView(waterViewModel: waterViewModel, dailyGoal: 2.8)
                    .padding(.vertical, 10)
                    
                    // Food List with addFoodAction closure passed in
                    FoodListView(
                        viewModel: viewModel,
                        addFoodAction: { mealType in
                            openAddFoodView(for: mealType)
                        }
                    )
                    
                    // Weight Progress Chart
                   
                }
                .padding(.horizontal, 16)
            }
            .background(Color.clear)
            .navigationBarTitle(todayString, displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.primary)
                }
            )
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .background(NavigationConfigurator { navController in
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.clear // Fully transparent
                appearance.shadowColor = .clear // Removes separator lines
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Text color
                
                navController.navigationBar.standardAppearance = appearance
                navController.navigationBar.scrollEdgeAppearance = appearance
            })
        }
    }
    
    // Function to open AddFoodView with a preselected meal type
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

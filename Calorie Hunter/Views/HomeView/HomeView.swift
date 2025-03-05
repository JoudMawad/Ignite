import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FoodViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Sliding Charts Section
                    TabView {
                        CalorieChartView(viewModel: userProfileViewModel, totalCalories: viewModel.totalCalories)
                        
                        FoodChartView(
                            totalProtein: viewModel.totalProtein,
                            totalCarbs: viewModel.totalCarbs,
                            totalFat: viewModel.totalFat
                        )
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 330)
                    .padding(.top, 10)
                    
                    // Add Food Button
                    ExpandingButton(title: "Add Food") {
                        openAddFoodView()
                    }
                    
                    // Food List
                    FoodListView(viewModel: viewModel)
                    
                    // Weight Progress Chart
                    WeightChartView(
                        startWeight: userProfileViewModel.startWeight,
                        viewModel: userProfileViewModel,
                        onWeightChange: {
                            userProfileViewModel.saveProfile()
                        }
                    )
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.clear) // Ensures no background blur
            .navigationBarTitle("Home", displayMode: .inline)
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

    private func openAddFoodView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let addFoodView = AddFoodView(viewModel: viewModel)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

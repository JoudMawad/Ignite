import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var viewModel = FoodViewModel()
    @StateObject var userProfileViewModel = UserProfileViewModel()  // Single shared instance

    @State private var showSettings = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Charts scroll with sections
                    TabView {
                        CalorieChartView(viewModel: UserProfileViewModel() , totalCalories: viewModel.totalCalories)
                        UserProfileView(viewModel: UserProfileViewModel())

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
                        currentWeight: $userProfileViewModel.currentWeight,
                        goalWeight: userProfileViewModel.goalWeight,
                        onWeightChange: {
                            userProfileViewModel.updateCurrentWeight(userProfileViewModel.currentWeight)
                        }
                    )
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 16)
            }
            .navigationBarItems(
                leading: Button(action: {
                    showSettings = true  // Open Settings Page instead of Profile
                }) {
                    Image(systemName: "gearshape.fill")  // Changed to settings icon
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.primary)
                }
            )
            .sheet(isPresented: $showSettings) {
                SettingsView() // Opens the Settings Page
            }
            .ignoresSafeArea(.keyboard)
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


#Preview {
    ContentView()
}

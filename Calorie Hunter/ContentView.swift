import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var viewModel = FoodViewModel()
    @State private var showUserProfile = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // ✅ Charts scroll with sections
                    TabView {
                        CalorieChartView(totalCalories: viewModel.totalCalories)
                        
                        FoodChartView(
                            totalProtein: viewModel.totalProtein,
                            totalCarbs: viewModel.totalCarbs,
                            totalFat: viewModel.totalFat
                        )
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 330)
                    .padding(.top, 10)

                    ExpandingButton(title: "Add Food") {
                        openAddFoodView()
                    }
                    
                    ExpandingButton(title: "Reset") {
                        viewModel.resetToday()
                    }

                    // ✅ Food Sections Scroll With Charts
                    FoodListView(viewModel: viewModel)

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationBarItems(
                leading: Button(action: {
                    showUserProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            )
            .sheet(isPresented: $showUserProfile) {
                UserProfileView()
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

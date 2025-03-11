import SwiftUI

struct HomeView: View {
   @ObservedObject var viewModel: FoodViewModel
   @ObservedObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
   
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
                   // Charts Section: The background is a rounded rectangle that will extend to the very top.
                   ZStack {
                       // Background RoundedRectangle that covers left, right, and top edges.
                       RoundedRectangle(cornerRadius: 60)
                           .fill(colorScheme == .dark ? Color.white : Color.black)
                           .shadow(radius: 5, x: 0, y: 4)
                           .frame(height: 450)
                           .frame(maxWidth: .infinity)
                           // Ignore safe area so that it reaches the very top.
                           .edgesIgnoringSafeArea(.top)
                           .padding(2.5)
                       
                       // TabView with charts placed on top of the background.
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
                       .padding(.top, 70)
                   }
                   // No extra horizontal padding for the charts section.
                   .frame(maxWidth: .infinity)
                   
                   // Subsequent content gets its own horizontal padding.
                   WaterProgressView(waterViewModel: waterViewModel, dailyGoal: 2.8)
                       .padding(.vertical, 10)
                       .padding(.bottom, 14)
                       .padding(.horizontal, 16)
                   
                   FoodListView(
                       viewModel: viewModel,
                       addFoodAction: { mealType in
                           openAddFoodView(for: mealType)
                       }
                   )
                   .padding(.horizontal, 16)
               }
           }
           // Force the entire ScrollView to ignore the top safe area.
           .edgesIgnoringSafeArea(.top)
           .background(Color.clear)
           .navigationBarTitle(todayString, displayMode: .inline)
           .navigationBarItems(
               leading: Button(action: {
                   showSettings = true
               }) {
                   Image(systemName: "gearshape.fill")
                       .resizable()
                       .frame(width: 30, height: 30)
                       .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
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

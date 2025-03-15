import SwiftUI

// MARK: - Default Profile Extension
extension UserProfile {
    static var defaultProfile: UserProfile {
        let context = PersistenceController.shared.container.viewContext
        let profile = UserProfile(context: context)
        profile.name = "Default User"
        profile.gender = "M"
        profile.age = 25
        profile.height = 170
        profile.dailyCalorieGoal = 1500
        profile.startWeight = 70.0
        profile.currentWeight = 70.0
        profile.goalWeight = 65.0
        profile.profileImageData = nil
        return profile
    }
}

// MARK: - ChartsView
/// A view that displays various chart carousels including calorie, weight, BMR, water, steps, and burned calories charts.
struct ChartsView: View {
    // Observed view model for food-related data.
    @ObservedObject var foodViewModel: FoodViewModel
    // Observed view model for user profile data.
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    // Create a water view model.
    @StateObject var waterViewModel = WaterViewModel(container: PersistenceController.shared.container)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    // Header text for the charts screen.
                    Text("Charts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // MARK: Calorie Charts Carousel
                    ChartCarouselView(charts: [
                        // Weekly calorie chart.
                        AnyView(WeeklyCalorieChartView(viewModel: foodViewModel)),
                        // Monthly calorie chart.
                        AnyView(MonthlyCalorieChartView(viewModel: foodViewModel)),
                        // Yearly calorie chart.
                        AnyView(YearlyCalorieChartView(viewModel: foodViewModel))
                    ])
                    
                    Spacer()
                    
                    // MARK: Burned Calories Charts Carousel
                    ChartCarouselView(charts: [
                        // Weekly burned calories chart.
                        AnyView(WeeklyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared)),
                        // Monthly burned calories chart.
                        AnyView(MonthlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared)),
                        // Yearly burned calories chart.
                        AnyView(YearlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared))
                    ])
                    
                    Spacer()
                    
                    // MARK: Weight Charts Carousel
                    ChartCarouselView(charts: [
                        // Weekly weight chart.
                        AnyView(WeeklyWeightChartView(viewModel: userProfileViewModel)),
                        AnyView(MonthlyWeightChartView()),
                        AnyView(YearlyWeightChartView())
                    ])
                    
                    Spacer()
                    
                    // MARK: BMR Charts Carousel
                    ChartCarouselView(charts: [
                        AnyView(WeeklyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(MonthlyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(YearlyBMRChartView(viewModel: userProfileViewModel))
                    ])
                    
                    Spacer()
                    
                    // MARK: Water Charts Carousel
                    ChartCarouselView(charts: [
                        AnyView(WeeklyWaterChartView(waterManager: waterViewModel)),
                        AnyView(MonthlyWaterChartView(waterManager: waterViewModel)),
                        AnyView(YearlyWaterChartView(waterManager: waterViewModel))
                    ])
                    
                    Spacer()
                    
                    // MARK: Steps Charts Carousel
                    ChartCarouselView(charts: [
                        AnyView(WeeklyStepsChartView(stepsManager: StepsHistoryManager.shared)),
                        AnyView(MonthlyStepsChartView(stepsManager: StepsHistoryManager.shared)),
                        AnyView(YearlyStepsChartView(stepsManager: StepsHistoryManager.shared))
                    ])
                    
                    Spacer()
                }
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ChartsView(foodViewModel: FoodViewModel(), userProfileViewModel: UserProfileViewModel())
}

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
/// A view that displays various chart carousels including calorie, weight, BMR, and steps charts.
struct ChartsView: View {
    // Observed view model for food-related data.
    @ObservedObject var foodViewModel: FoodViewModel
    // Observed view model for user profile data.
    @ObservedObject var userProfileViewModel: UserProfileViewModel

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
                    
                    // MARK: Weight Charts Carousel
                    ChartCarouselView(charts: [
                        // Weekly weight chart.
                        // Use the loaded Core Data profile or a default if it's nil.
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

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

// MARK: - Scroll Visual Effect Modifier
/// A custom view modifier that applies scroll-based transformations.
struct ScrollVisualEffect: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollTransition(.animated.threshold(.visible(0.75))) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.5)
                .scaleEffect(phase.isIdentity ? 1 : 0.90)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}

extension View {
    /// Applies a scroll-based visual effect.
    func scrollVisualEffect() -> some View {
        self.modifier(ScrollVisualEffect())
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
                LazyVStack(spacing: 20) {
                    // Header text for the charts screen.
                    Text("Charts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // MARK: Calorie Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyCalorieChartView(viewModel: foodViewModel)),
                        AnyView(MonthlyCalorieChartView(viewModel: foodViewModel)),
                        AnyView(YearlyCalorieChartView(viewModel: foodViewModel))
                    ])
                    .scrollVisualEffect()
                    
                    // MARK: Burned Calories Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared)),
                        AnyView(MonthlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared)),
                        AnyView(YearlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager.shared))
                    ])
                    .scrollVisualEffect()
                    
                    // MARK: Weight Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyWeightChartView(viewModel: userProfileViewModel)),
                        AnyView(MonthlyWeightChartView()),
                        AnyView(YearlyWeightChartView())
                    ])
                    .scrollVisualEffect()
                    
                    // MARK: BMR Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(MonthlyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(YearlyBMRChartView(viewModel: userProfileViewModel))
                    ])
                    .scrollVisualEffect()
                    
                    // MARK: Water Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyWaterChartView(waterManager: waterViewModel)),
                        AnyView(MonthlyWaterChartView(waterManager: waterViewModel)),
                        AnyView(YearlyWaterChartView(waterManager: waterViewModel))
                    ])
                    .scrollVisualEffect()
                    
                    // MARK: Steps Charts Carousel with visual effect
                    ChartCarouselView(charts: [
                        AnyView(WeeklyStepsChartView(stepsManager: StepsHistoryManager.shared)),
                        AnyView(MonthlyStepsChartView(stepsManager: StepsHistoryManager.shared)),
                        AnyView(YearlyStepsChartView(stepsManager: StepsHistoryManager.shared))
                    ])
                    .scrollVisualEffect()
                }
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ChartsView(foodViewModel: FoodViewModel(),
               userProfileViewModel: UserProfileViewModel())
}

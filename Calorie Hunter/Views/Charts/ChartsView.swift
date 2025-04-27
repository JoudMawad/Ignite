import SwiftUI
import Charts

// MARK: - Default Profile Extension
/// Provides a default user profile used as a fallback or initial state.
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
/// A custom view modifier that applies scroll-based visual transformations.
/// As the view scrolls, its opacity, scale, and blur change to create an animated effect.
struct ScrollVisualEffect: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollTransition(.animated.threshold(.visible(0.75))) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.5)    // Fade view when not fully visible.
                .scaleEffect(phase.isIdentity ? 1 : 0.90) // Slightly shrink view when scrolling.
                .blur(radius: phase.isIdentity ? 0 : 2)   // Apply blur when view is transitioning.
        }
    }
}

extension View {
    /// Convenience method to apply the scroll-based visual effect.
    func scrollVisualEffect() -> some View {
        self.modifier(ScrollVisualEffect())
    }
}

// MARK: - ChartsView
/// The main view that displays various chart carousels for tracking nutrition, weight, BMR, water, steps, and burned calories.
struct ChartsView: View {
    // Observed view model for food-related data (e.g., calorie charts).
    @ObservedObject var foodViewModel: FoodViewModel
    // Observed view model for user profile data (e.g., weight, BMR charts).
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    // A state object for water tracking, initialized with the shared Persistence container.
    @StateObject var waterViewModel = WaterViewModel(container: PersistenceController.shared.container)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header for the charts screen.
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
                    .scrollVisualEffect() // Apply custom scroll effect
                    
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
                // Ensure the background covers the full scrollable area.
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            }
        }
    }
}

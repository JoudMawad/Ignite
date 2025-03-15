import SwiftUI

struct HealthGoalsSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                OnboardingInputCellDouble(
                    title: "Weight",
                    placeholder: String(viewModel.startWeight),
                    systemImageName: "scalemass",
                    value: $viewModel.startWeight
                )
                OnboardingInputCellDouble(
                    title: "Goal Weight",
                    placeholder: String(viewModel.goalWeight),
                    systemImageName: "target",
                    value: $viewModel.goalWeight
                )
            }
            HStack{
                OnboardingInputCellInt(
                    title: "Goal Calories",
                    placeholder: String(viewModel.dailyCalorieGoal),
                    systemImageName: "flame.fill",
                    value: $viewModel.dailyCalorieGoal
                )
                
                OnboardingInputCellInt(
                    title: "Steps Goal",
                    placeholder: String(viewModel.dailyStepsGoal),
                    systemImageName: "figure.walk",
                    value: $viewModel.dailyStepsGoal
                )
            }
            
            OnboardingInputCellInt(
                title: "Activity Goal",
                placeholder: String(viewModel.dailyBurnedCaloriesGoal),
                systemImageName: "flame",
                value: $viewModel.dailyBurnedCaloriesGoal
            )
        }
    }
}

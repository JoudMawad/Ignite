import SwiftUI

struct HealthGoalsSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                OnboardingInputCellDouble(
                    title: "Weight",
                    placeholder: "....",
                    systemImageName: "scalemass",
                    value: $viewModel.startWeight
                )
                OnboardingInputCellDouble(
                    title: "Goal Weight",
                    placeholder: "....",
                    systemImageName: "target",
                    value: $viewModel.goalWeight
                )
            }
            OnboardingInputCellInt(
                title: "Goal Calories",
                placeholder: "....",
                systemImageName: "flame.fill",
                value: $viewModel.dailyCalorieGoal
            )
        }
    }
}

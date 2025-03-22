import SwiftUI

struct HealthGoalsSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AnimatedCard {
                    Text("Health Goals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                }
                
                AnimatedCard {
                    OnboardingInputCellDouble(
                        title: "Weight",
                        placeholder: String(viewModel.startWeight),
                        systemImageName: "scalemass",
                        value: $viewModel.startWeight
                    )
                }
                
                AnimatedCard {
                    OnboardingInputCellDouble(
                        title: "Goal Weight",
                        placeholder: String(viewModel.goalWeight),
                        systemImageName: "target",
                        value: $viewModel.goalWeight
                    )
                }
                
                AnimatedCard {
                    OnboardingInputCellInt(
                        title: "Goal Calories",
                        placeholder: String(viewModel.dailyCalorieGoal),
                        systemImageName: "flame.fill",
                        value: $viewModel.dailyCalorieGoal
                    )
                }
                
                AnimatedCard {
                    OnboardingInputCellInt(
                        title: "Steps Goal",
                        placeholder: String(viewModel.dailyStepsGoal),
                        systemImageName: "figure.walk",
                        value: $viewModel.dailyStepsGoal
                    )
                }
                
                AnimatedCard {
                    OnboardingInputCellInt(
                        title: "Activity Goal",
                        placeholder: String(viewModel.dailyBurnedCaloriesGoal),
                        systemImageName: "flame",
                        value: $viewModel.dailyBurnedCaloriesGoal
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, -60)
    }
}

import SwiftUI

struct HealthGoalsSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var activityLevel: ActivityLevel = .sedentary
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AnimatedCard {
                    Text("Health Goals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                }
                
                HStack {
                    
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
                    
                }
                
                HStack {
                    
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
                    

                AnimatedCard {
                    OnboardingInputCellDouble(
                        title: "Water Goal (L)",
                        placeholder: String(viewModel.dailyWaterGoal),
                        systemImageName: "drop.fill",
                        value: $viewModel.dailyWaterGoal
                    )
                }
                
                AnimatedCard {
                    CalorieGoalSliderView(
                        age: viewModel.age,
                        height: Double(viewModel.height),
                        weight: viewModel.currentWeight,
                        gender: viewModel.gender,
                        weeklyChange: $viewModel.weeklyWeightChangeGoal
                    ) { newGoal in
                        viewModel.dailyCalorieGoal = newGoal
                    }
                    .onAppear {
                        viewModel.loadProfile()
                    }
                }
                                            
                
                    
            }
            .padding(.horizontal)
        }
        .padding(.top, -60)
    }
}

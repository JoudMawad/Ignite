import SwiftUI

struct HealthGoalsSectionView: View {
    @ObservedObject var goalsViewModel: GoalsViewModel
    @ObservedObject var userprofileviewModel: UserProfileViewModel
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
                            placeholder: String(goalsViewModel.goalWeight),
                            systemImageName: "target",
                            value: $goalsViewModel.goalWeight
                        )
                    }
                    
                    AnimatedCard {
                        OnboardingInputCellInt(
                            title: "Goal Calories",
                            placeholder: String(goalsViewModel.dailyCalorieGoal),
                            systemImageName: "flame.fill",
                            value: $goalsViewModel.dailyCalorieGoal
                        )
                    }
                    
                }
                
                HStack {
                    
                    AnimatedCard {
                        OnboardingInputCellInt(
                            title: "Steps Goal",
                            placeholder: String(goalsViewModel.dailyStepsGoal),
                            systemImageName: "figure.walk",
                            value: $goalsViewModel.dailyStepsGoal
                        )
                    }
                    
                    AnimatedCard {
                        OnboardingInputCellInt(
                            title: "Activity Goal",
                            placeholder: String(goalsViewModel.dailyBurnedCaloriesGoal),
                            systemImageName: "flame",
                            value: $goalsViewModel.dailyBurnedCaloriesGoal
                        )
                    }
                }
                    

                AnimatedCard {
                    OnboardingInputCellDouble(
                        title: "Water Goal (L)",
                        placeholder: String(goalsViewModel.dailyWaterGoal),
                        systemImageName: "drop.fill",
                        value: $goalsViewModel.dailyWaterGoal
                    )
                }
                
                AnimatedCard {
                    CalorieGoalSliderView(
                        age: userprofileviewModel.age,
                        height: Double(userprofileviewModel.height),
                        weight: userprofileviewModel.currentWeight,
                        gender: userprofileviewModel.gender,
                        weeklyChange: $goalsViewModel.weeklyWeightChangeGoal
                    ) { newGoal in
                        goalsViewModel.dailyCalorieGoal = newGoal
                    }
                    .onAppear {
                        userprofileviewModel.loadProfile()
                    }
                }
                                            
                
                    
            }
            .padding(.horizontal)
        }
        .padding(.top, -60)
    }
}

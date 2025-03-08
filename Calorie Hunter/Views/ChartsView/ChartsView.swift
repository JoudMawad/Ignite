import SwiftUI

struct ChartsView: View {
    @ObservedObject var foodViewModel: FoodViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {

                    Text("Charts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    ChartCarouselView(charts: [
                        // ✅ Calorie Charts
                        AnyView(WeeklyCalorieChartView(viewModel: foodViewModel)),
                        AnyView(MonthlyCalorieChartView(viewModel: foodViewModel)),
                        AnyView(YearlyCalorieChartView(viewModel: foodViewModel)),
                    ])
                    
                    
                    Spacer()
                    
                    ChartCarouselView(charts: [
                        
                        // ✅ Weight Charts
                        AnyView(WeeklyWeightChartView()),
                        AnyView(MonthlyWeightChartView()),
                        AnyView(YearlyWeightChartView())
                    ])
                    
                    Spacer()
                    
                    ChartCarouselView(charts: [
                        
                        // ✅ Weight Charts
                        AnyView(WeeklyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(MonthlyBMRChartView(viewModel: userProfileViewModel)),
                        AnyView(YearlyBMRChartView(viewModel: userProfileViewModel))
                    ])
                    
                    ChartCarouselView(charts: [
                        
                        // ✅ Weight Charts
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

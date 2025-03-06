import SwiftUI

struct ChartsView: View {
    @ObservedObject var viewModel: FoodViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Calorie Charts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Spacer()

                ChartCarouselView(charts: [
                    AnyView(WeeklyCalorieChartView(viewModel: viewModel)),
                    AnyView(MonthlyCalorieChartView(viewModel: viewModel)),
                    AnyView(YearlyCalorieChartView(viewModel: viewModel))
                ])

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    ChartsView(viewModel: FoodViewModel())
}

import SwiftUI

struct ChartsView: View {
    @ObservedObject var viewModel: FoodViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Charts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                ChartCarouselView(charts: [
                    AnyView(WeeklyCalorieChartView(viewModel: viewModel)),
                    AnyView(MonthlyCalorieChartView(viewModel: viewModel)),
                    AnyView(YearlyCalorieChartView(viewModel: viewModel))
                ])

                Spacer()
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    ChartsView(viewModel: FoodViewModel())
}

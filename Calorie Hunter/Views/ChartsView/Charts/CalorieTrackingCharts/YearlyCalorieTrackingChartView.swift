import SwiftUI
import Charts

struct YearlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: calorieData.map { (date: $0.date, value: Double($0.calories)) },
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
        .map { (label: $0.label, calories: Int($0.aggregatedValue)) }
    }
    
    func maxCalorieValue() -> Int {
        (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Calories",
                subtitle: "Year",
                yDomain: 0...Double(maxCalorieValue()),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Calories", entry.calories)
                        )
                        .commonStyle(gradientColors: [.cyan, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct YearlyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

import SwiftUI
import Charts

struct WeeklyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return (0..<7).map { offset -> (String, Int) in
            let date = calendar.date(byAdding: .day, value: -offset, to: yesterday)!
            let dateString = ChartDataHelper.dateToString(date)
            let calories = calorieData.first(where: { $0.date == dateString })?.calories ?? 0
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), calories)
        }.reversed()
    }
    
    func maxCalorieValue() -> Int {
        (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Calories",
                subtitle: "Week",
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

struct WeeklyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

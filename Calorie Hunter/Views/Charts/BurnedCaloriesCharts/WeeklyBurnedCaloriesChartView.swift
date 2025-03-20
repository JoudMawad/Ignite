import SwiftUI
import Charts

struct WeeklyBurnedCaloriesChartView: View {
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    var burnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: burnedCaloriesData,
            days: 7,
            interval: 1,
            outputDateFormat: "EEE"
        )
    }
    
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Week",
                yDomain: 0...maxBurnedCaloriesValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        .commonStyle(gradientColors: [.red, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct WeeklyBurnedCaloriesChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager())
            .preferredColorScheme(.dark)
    }
}

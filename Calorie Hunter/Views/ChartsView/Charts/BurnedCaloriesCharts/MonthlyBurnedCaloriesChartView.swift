import SwiftUI
import Charts

struct MonthlyBurnedCaloriesChartView: View {
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    var burnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: burnedCaloriesData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
    }
    
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Month",
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

struct MonthlyBurnedCaloriesChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager())
            .preferredColorScheme(.dark)
    }
}

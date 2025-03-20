import SwiftUI
import Charts

struct YearlyBurnedCaloriesChartView: View {
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    var rawBurnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: rawBurnedCaloriesData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Year",
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

struct YearlyBurnedCaloriesChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyBurnedCaloriesChartView(burnedCaloriesManager: BurnedCaloriesHistoryManager())
            .preferredColorScheme(.dark)
    }
}

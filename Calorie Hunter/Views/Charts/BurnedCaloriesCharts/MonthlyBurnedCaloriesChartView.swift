import SwiftUI
import Charts

struct MonthlyBurnedCaloriesChartView: View {
    // Manager providing burned calories history data for the specified period.
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    // Environment variable to adapt chart styling to the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieves burned calories data for the last 30 days.
    var burnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 30)
    }
    
    /// Groups the raw burned calories data into 5-day intervals.
    /// The result maps each interval to a formatted date label and its associated total burned calories.
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: burnedCaloriesData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
    }
    
    /// Calculates the maximum burned calories value from the formatted data, adding a buffer for visual padding.
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Month",
                // Set the y-axis domain from 0 to the calculated max value.
                yDomain: 0...maxBurnedCaloriesValue(),
                chartContent: {
                    // Iterate through the formatted data to create chart line marks.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        // Apply a common style with a red gradient and adaptive contrast.
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

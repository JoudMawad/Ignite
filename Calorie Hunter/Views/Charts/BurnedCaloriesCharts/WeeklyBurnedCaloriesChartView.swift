import SwiftUI
import Charts

struct WeeklyBurnedCaloriesChartView: View {
    // Manager providing burned calories history data for the week.
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    // Adapts visual styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieves burned calories data for the last 7 days.
    var burnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 7)
    }
    
    /// Groups daily burned calories data by day, using abbreviated weekday labels.
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: burnedCaloriesData,
            days: 7,
            interval: 1,
            outputDateFormat: "EEE" // Abbreviated weekday (e.g., Mon, Tue)
        )
    }
    
    /// Calculates the maximum burned calories value with a padding buffer,
    /// ensuring the chart's y-axis has sufficient headroom.
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Week",
                // Define y-axis domain from 0 up to the buffered maximum value.
                yDomain: 0...maxBurnedCaloriesValue(),
                chartContent: {
                    // Create a line mark for each day using the formatted data.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        // Apply a red gradient that adapts to dark/light mode for contrast.
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

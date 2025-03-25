import SwiftUI
import Charts

struct YearlyBurnedCaloriesChartView: View {
    // Provides yearly burned calories data.
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    // Adapts UI elements based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieves raw burned calories data for the last 365 days.
    var rawBurnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 365)
    }
    
    /// Groups the raw data into 90-day intervals and formats date labels (e.g., "Jan 23").
    var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: rawBurnedCaloriesData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    /// Computes the maximum burned calories value from the grouped data and adds a buffer for chart spacing.
    func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Burned Calories",
                subtitle: "Year",
                // Y-axis starts at 0 and extends to the buffered maximum value.
                yDomain: 0...maxBurnedCaloriesValue(),
                chartContent: {
                    // Render a line mark for each 90-day interval.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        // Apply a gradient style that adapts to the current color scheme.
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

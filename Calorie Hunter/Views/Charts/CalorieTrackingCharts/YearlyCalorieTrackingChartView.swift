import SwiftUI
import Charts

struct YearlyCalorieChartView: View {
    // ViewModel providing access to food and calorie data.
    @ObservedObject var viewModel: FoodViewModel
    // Adapts styling based on the current light or dark mode.
    @Environment(\.colorScheme) var colorScheme
    // Manager for retrieving historical calorie data.
    private let historyManager = CalorieHistoryManager()
    
    /// Retrieves raw calorie data for the past 365 days.
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 365)
    }
    
    /// Groups the raw calorie data into 90-day intervals.
    /// Zeros are included for missing intervals, ensuring continuous chart display.
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: calorieData.map { (date: $0.date, value: Double($0.calories)) },
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"  // Format label as abbreviated month and year (e.g., "Jan 23").
        )
        .map { (label: $0.label, calories: Int($0.aggregatedValue)) }
    }
    
    /// Determines the maximum calorie value from the grouped data and adds a buffer.
    /// This provides extra space on the chart's y-axis for visual clarity.
    func maxCalorieValue() -> Int {
        (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Calories",
                subtitle: "Year",
                // Set the y-axis domain from 0 to the maximum calculated value.
                yDomain: 0...Double(maxCalorieValue()),
                chartContent: {
                    // Iterate over the grouped data to plot line marks.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Calories", entry.calories)
                        )
                        // Apply a common style with a cyan gradient that adapts to the color scheme.
                        .commonStyle(gradientColors: [.cyan, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

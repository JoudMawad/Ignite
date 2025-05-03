import SwiftUI
import Charts

struct MonthlyCalorieChartView: View {
    // View model containing food-related data.
    @ObservedObject var viewModel: FoodViewModel
    // Environment variable to adjust UI styling based on light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieves raw calorie data for the past 30 days.
    var calorieData: [(date: String, calories: Int)] {
        viewModel.totalCalories(forLast: 30)
    }
    
    /// Groups the raw calorie data into 5-day intervals while including zero values.
    /// This helps maintain continuity in the chart even if there are missing days.
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: calorieData.map { (date: $0.date, value: Double($0.calories)) },
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
        .map { (label: $0.label, calories: Int($0.aggregatedValue)) }
    }
    
    /// Computes the maximum calorie value from the formatted data and adds a buffer
    /// for visual spacing on the chart's y-axis.
    func maxCalorieValue() -> Int {
        (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Calories",
                subtitle: "Month",
                // Define the y-axis domain from 0 to the buffered maximum value.
                yDomain: 0...Double(maxCalorieValue()),
                chartContent: {
                    // Iterate over each grouped data entry to plot a line mark.
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

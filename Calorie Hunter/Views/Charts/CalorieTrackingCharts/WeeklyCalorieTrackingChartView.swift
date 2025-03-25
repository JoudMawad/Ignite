import SwiftUI
import Charts

struct WeeklyCalorieChartView: View {
    // FoodViewModel provides access to food data including calorie goals.
    @ObservedObject var viewModel: FoodViewModel
    // Adapt UI styling based on light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    // Manager responsible for retrieving historical calorie data.
    private let historyManager = CalorieHistoryManager()
    
    /// Retrieves calorie data for the last 7 days.
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 7)
    }
    
    /// Formats the raw calorie data to map each day of the week to its calorie count.
    /// This method ensures that each day (in abbreviated weekday format) is represented,
    /// using zero calories when no data is found for that day.
    var formattedData: [(label: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        // We use yesterday as the starting point to ensure a full week is covered.
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return (0..<7).map { offset -> (String, Int) in
            // Calculate the date for the given offset.
            let date = calendar.date(byAdding: .day, value: -offset, to: yesterday)!
            // Convert the date to a string to match against stored data.
            let dateString = ChartDataHelper.dateToString(date)
            // Retrieve calorie data for the date, defaulting to 0 if missing.
            let calories = calorieData.first(where: { $0.date == dateString })?.calories ?? 0
            // Format the date to its abbreviated weekday (e.g., Mon, Tue).
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), calories)
        }
        .reversed() // Reverse the array to show the oldest day first.
    }
    
    /// Determines the maximum calorie value from the formatted data,
    /// adding a buffer to provide visual headroom on the chart's y-axis.
    func maxCalorieValue() -> Int {
        (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Calories",
                subtitle: "Week",
                // Set the y-axis domain from 0 up to the buffered maximum calorie value.
                yDomain: 0...Double(maxCalorieValue()),
                chartContent: {
                    // Iterate over the formatted data to plot the calorie consumption for each day.
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

struct WeeklyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

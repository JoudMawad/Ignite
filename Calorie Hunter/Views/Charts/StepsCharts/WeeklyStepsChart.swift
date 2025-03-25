import SwiftUI
import Charts

struct WeeklyStepsChartView: View {
    // Manager that provides the steps history data for the past week.
    @ObservedObject var stepsManager: StepsHistoryManager
    // Access the current color scheme to adapt the chart's appearance.
    @Environment(\.colorScheme) var colorScheme

    /// Retrieve raw step data for the last 7 days.
    var rawStepsData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 7)
    }
    
    /// Group the raw steps data into daily data points.
    /// The output date format "EEE" produces abbreviated weekday names (e.g., Mon, Tue).
    var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: rawStepsData,
            days: 7,
            interval: 1,
            outputDateFormat: "EEE"
        )
    }
    
    /// Calculate the maximum step count from the formatted data, then add a buffer
    /// to ensure the chart's y-axis has some headroom.
    func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 0) + 50
    }
    
    var body: some View {
        // ChartCardOrangeView provides the card styling for the chart.
        ChartCardOrangeView {
            // BaseChartView constructs the chart with a title, subtitle, and defined y-axis domain.
            BaseChartView(
                title: "Steps",
                subtitle: "Week",
                // Set the y-axis range from 0 to the maximum step count plus a buffer.
                yDomain: 0...Double(maxStepValue()),
                chartContent: {
                    // Iterate through each day's data and create a line mark.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Steps", entry.steps)
                        )
                        // Apply a common style with an orange gradient that adapts to the current color scheme.
                        .commonStyle(gradientColors: [.orange, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct WeeklyStepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyStepsChartView(stepsManager: StepsHistoryManager())
            .preferredColorScheme(.dark)
    }
}

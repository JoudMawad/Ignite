import SwiftUI
import Charts

struct YearlyStepsChartView: View {
    // Manager providing step history data for the past year.
    @ObservedObject var stepsManager: StepsHistoryManager
    // Adapts UI elements based on light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieve raw steps data for the past 365 days.
    var rawStepsData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 365)
    }
    
    /// Group the raw data into 90-day intervals.
    /// The outputDateFormat "MMM yy" results in labels like "Jan 23".
    var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: rawStepsData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    /// Calculate the maximum steps value among the grouped data and add a buffer (50).
    /// This buffer provides visual spacing on the chart's y-axis.
    func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 0) + 50
    }
    
    var body: some View {
        // ChartCardOrangeView provides the overall card styling.
        ChartCardOrangeView {
            BaseChartView(
                title: "Steps",
                subtitle: "Year",
                // Set the y-axis domain from 0 to the maximum steps value plus buffer.
                yDomain: 0...Double(maxStepValue()),
                chartContent: {
                    // Iterate over grouped data to plot each interval as a line mark.
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

struct YearlyStepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyStepsChartView(stepsManager: StepsHistoryManager())
            .preferredColorScheme(.dark)
    }
}

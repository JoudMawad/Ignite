import SwiftUI
import Charts

struct MonthlyStepsChartView: View {
    // Observed object that provides step history data.
    @ObservedObject var stepsManager: StepsHistoryManager
    // Adapts UI styling based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieves raw step data for the past 30 days.
    var stepData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 30)
    }
    
    /// Groups the step data into 5-day intervals and formats the date labels.
    var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: stepData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d" // e.g., "Jan 5"
        )
    }
    
    /// Computes the maximum steps value from the formatted data and adds a buffer
    /// for better visual spacing on the chart's y-axis.
    func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardOrangeView {
            BaseChartView(
                title: "Steps",
                subtitle: "Month",
                // Define the y-axis domain from 0 to the computed maximum step value.
                yDomain: 0...Double(maxStepValue()),
                chartContent: {
                    // Plot a line mark for each grouped data entry.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Steps", entry.steps)
                        )
                        // Apply a common style with an orange gradient that adapts based on the color scheme.
                        .commonStyle(gradientColors: [.orange, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct MonthlyStepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyStepsChartView(stepsManager: StepsHistoryManager())
            .preferredColorScheme(.dark)
    }
}

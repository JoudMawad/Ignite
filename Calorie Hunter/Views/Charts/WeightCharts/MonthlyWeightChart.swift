import SwiftUI
import Charts

struct MonthlyWeightChartView: View {
    // Adapt the UI based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    // Use a shared instance of WeightHistoryManager to retrieve weight data.
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    
    /// Retrieve weight data for the past 30 days.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    /// Group the raw weight data into 5-day intervals.
    /// The date labels are formatted using "MMM d" (e.g., "Jan 5").
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
    }
    
    /// Compute the maximum weight value from the grouped data.
    /// Only consider values greater than 0 and add a buffer (2 units) for visual spacing.
    func maxWeightValue() -> Double {
        let maxWeight = formattedData.map { $0.weight }.filter { $0 > 0 }.max() ?? 100
        return maxWeight + 2
    }
    
    /// Compute the minimum weight value from the grouped data.
    /// Only consider values greater than 0 and subtract a buffer (2 units) for visual spacing.
    func minWeightValue() -> Double {
        let minWeight = formattedData.map { $0.weight }.filter { $0 > 0 }.min() ?? 50
        return minWeight - 2
    }
    
    var body: some View {
        // ChartCardPurpleView provides the purple-themed card styling.
        ChartCardPurpleView {
            BaseChartView(
                title: "Weight",
                subtitle: "Month",
                // Define the y-axis domain using the computed minimum and maximum weight values.
                yDomain: minWeightValue()...maxWeightValue(),
                chartContent: {
                    // Iterate through the grouped weight data to plot each data point as a line mark.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
                        // Apply a common style using a purple gradient that adapts to the current color scheme.
                        .commonStyle(gradientColors: [.purple, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct MonthlyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyWeightChartView()
            .preferredColorScheme(.dark)
    }
}

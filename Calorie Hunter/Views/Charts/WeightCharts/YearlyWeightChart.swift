import SwiftUI
import Charts

struct YearlyWeightChartView: View {
    // Use the shared instance of WeightHistoryManager to retrieve weight data.
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    // Adapt chart styling based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieve weight data for the past 365 days.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    /// Group the weight data into 90-day intervals.
    /// The output date format "MMM yy" produces concise labels (e.g., "Jan 23").
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    /// Compute the maximum weight from the grouped data and add a buffer for visual spacing.
    func maxWeightValue() -> Double {
        (formattedData.map { $0.weight }.max() ?? 100) + 2
    }
    
    /// Compute the minimum weight from the grouped data and subtract a buffer for visual spacing.
    func minWeightValue() -> Double {
        (formattedData.map { $0.weight }.min() ?? 50) - 2
    }
    
    var body: some View {
        // ChartCardPurpleView provides a purple-themed card background.
        ChartCardPurpleView {
            BaseChartView(
                title: "Weight",
                subtitle: "Year",
                // Set the y-axis domain using the computed min and max weight values.
                yDomain: minWeightValue()...maxWeightValue(),
                chartContent: {
                    // Iterate over the grouped weight data to create line marks.
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

struct YearlyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyWeightChartView()
            .preferredColorScheme(.dark)
    }
}

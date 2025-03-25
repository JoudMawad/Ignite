import SwiftUI
import Charts

struct YearlyWaterChartView: View {
    // ViewModel that supplies water intake data.
    @ObservedObject var waterManager: WaterViewModel
    // Adapt chart styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieve raw water intake data for the past 365 days.
    var rawWaterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 365)
    }
    
    /// Group the raw water data into 90-day intervals.
    /// The output date format "MMM yy" results in concise labels (e.g., "Jan 23").
    var formattedData: [(label: String, water: Double)] {
        let mappedData = rawWaterData.map { (date: $0.date, value: $0.water) }
        let grouped = ChartDataHelper.groupDataIncludingZeros(
            from: mappedData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
        return grouped.map { (label: $0.label, water: $0.aggregatedValue) }
    }
    
    /// Calculate the maximum water intake value from the grouped data,
    /// adding a buffer (6 units) for visual headroom on the chart's y-axis.
    func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 0) + 6
    }
    
    var body: some View {
        // ChartCardBlueView provides the blue-themed card styling.
        ChartCardBlueView {
            BaseChartView(
                title: "Water",
                subtitle: "Year",
                // Set the y-axis domain from 0 up to the computed maximum water value.
                yDomain: 0...maxWaterValue(),
                chartContent: {
                    // Iterate over the grouped data to plot each interval as a line mark.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Water", entry.water)
                        )
                        // Apply a common style with a blue gradient that adapts to the color scheme.
                        .commonStyle(gradientColors: [.blue, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

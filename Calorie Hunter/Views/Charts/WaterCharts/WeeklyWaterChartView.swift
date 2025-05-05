import SwiftUI
import Charts

struct WeeklyWaterChartView: View {
    // View model that supplies water intake data.
    @ObservedObject var waterManager: WaterViewModel
    // Adapt chart styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieve raw water data for the past 7 days.
    var rawWaterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 8)
    }
    
    /// Group the raw water data into daily intervals.
    /// The output date format "EEE" produces abbreviated weekday labels (e.g., Mon, Tue).
    var formattedData: [(label: String, water: Double)] {
        let mappedData = rawWaterData.map { (date: $0.date, value: $0.water) }
        let grouped = ChartDataHelper.groupDataIncludingZeros(
            from: mappedData,
            days: 7,
            interval: 1,
            outputDateFormat: "EEE"
        )
        return grouped.map { (label: $0.label, water: $0.aggregatedValue) }
    }
    
    /// Compute the maximum water intake from the grouped data and add a buffer.
    /// The added buffer (6 units) provides extra headroom on the chart's y-axis.
    func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 0) + 6
    }
    
    var body: some View {
        // ChartCardBlueView provides the card's styling.
        ChartCardBlueView {
            BaseChartView(
                title: "Water",
                subtitle: "Week",
                // Define the y-axis domain from 0 to the maximum water value.
                yDomain: 0...maxWaterValue(),
                chartContent: {
                    // Plot a line mark for each grouped data point.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Water", entry.water)
                        )
                        // Apply a common style with a blue gradient that adapts based on the color scheme.
                        .commonStyle(gradientColors: [.blue, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

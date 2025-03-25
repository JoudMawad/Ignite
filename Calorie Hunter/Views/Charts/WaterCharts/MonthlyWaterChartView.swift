import SwiftUI
import Charts

struct MonthlyWaterChartView: View {
    // View model that provides water intake data.
    @ObservedObject var waterManager: WaterViewModel
    // Adapts UI elements based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Retrieve water intake data for the past 30 days.
    var waterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 30)
    }
    
    /// Group water data into 5-day intervals and format the date labels.
    /// This ensures the x-axis labels (e.g., "Jan 5") remain clear and continuous,
    /// even if some days have zero intake.
    var formattedData: [(label: String, water: Double)] {
        let mappedData = waterData.map { (date: $0.date, value: $0.water) }
        let grouped = ChartDataHelper.groupDataIncludingZeros(
            from: mappedData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
        return grouped.map { (label: $0.label, water: $0.aggregatedValue) }
    }
    
    /// Compute the maximum water value from the grouped data and add a small buffer.
    /// The buffer (6 units) ensures the chart has some visual headroom.
    func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 100) + 6
    }
    
    var body: some View {
        // ChartCardBlueView provides the overall card styling.
        ChartCardBlueView {
            BaseChartView(
                title: "Water",
                subtitle: "Month",
                // Set the y-axis domain from 0 to the computed max water value.
                yDomain: 0...maxWaterValue(),
                chartContent: {
                    // Iterate over each grouped data point to create a line mark.
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Water", entry.water)
                        )
                        // Apply a common style with a blue gradient that adapts to the current color scheme.
                        .commonStyle(gradientColors: [.blue, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

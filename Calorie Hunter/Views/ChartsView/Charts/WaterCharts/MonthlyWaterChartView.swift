import SwiftUI
import Charts

struct MonthlyWaterChartView: View {
    @ObservedObject var waterManager: WaterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    /// Raw water intake data for the past 30 days (assumed to be 30 entries).
    private var waterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 30)
    }
    
    /// Group the 30 days into buckets of 5 days, labeling each bucket with "MMM d".
    private var formattedData: [(label: String, water: Double)] {
        // Map raw water data to match the helper's expected tuple type.
        let mappedData = waterData.map { (date: $0.date, value: $0.water) }
        let grouped = ChartDataHelper.groupDataIncludingZeros(
            from: mappedData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
        // Map the helper output back to use the "water" key.
        return grouped.map { (label: $0.label, water: $0.aggregatedValue) }
    }

    
    private func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 100) + 6
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Water")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Month")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Water", entry.water)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .pink]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: 0...maxWaterValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

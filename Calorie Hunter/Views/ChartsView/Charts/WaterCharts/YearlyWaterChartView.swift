import SwiftUI
import Charts

struct YearlyWaterChartView: View {
    @ObservedObject var waterManager: WaterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    /// Last 365 days of raw water intake data.
    private var rawWaterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 365)
    }
    
    /// Group the data into 90-day intervals, labeling each bucket with "MMM yy".
    private var formattedData: [(label: String, water: Double)] {
        let mappedData = rawWaterData.map { (date: $0.date, value: $0.water) }
        let grouped = ChartDataHelper.groupDataIncludingZeros(
            from: mappedData,
            days: 365,
            interval: 90,
            outputDateFormat: "EEE"
        )
        return grouped.map { (label: $0.label, water: $0.aggregatedValue) }
    }
    
    private func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 0) + 6
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Water")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("Year")
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

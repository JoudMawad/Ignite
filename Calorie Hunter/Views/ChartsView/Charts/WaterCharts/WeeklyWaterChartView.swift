import SwiftUI
import Charts

struct WeeklyWaterChartView: View {
    @ObservedObject var waterManager: WaterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var rawWaterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 7)
    }
    
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
    
    func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 0) + 6
    }
    
    var body: some View {
        ChartCardBlueView {
            BaseChartView(
                title: "Water",
                subtitle: "Week",
                yDomain: 0...maxWaterValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Water", entry.water)
                        )
                        .commonStyle(gradientColors: [.blue, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

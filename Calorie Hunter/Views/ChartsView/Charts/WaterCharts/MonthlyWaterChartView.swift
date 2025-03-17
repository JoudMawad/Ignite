import SwiftUI
import Charts

struct MonthlyWaterChartView: View {
    @ObservedObject var waterManager: WaterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var waterData: [(date: String, water: Double)] {
        waterManager.waterIntakesForPeriod(days: 30)
    }
    
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
    
    func maxWaterValue() -> Double {
        (formattedData.map { $0.water }.max() ?? 100) + 6
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Water",
                subtitle: "Month",
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

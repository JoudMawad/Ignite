import SwiftUI
import Charts

struct YearlyWeightChartView: View {
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    func maxWeightValue() -> Double {
        (formattedData.map { $0.weight }.max() ?? 100) + 2
    }
    
    func minWeightValue() -> Double {
        (formattedData.map { $0.weight }.min() ?? 50) - 2
    }
    
    var body: some View {
        ChartCardPinkView {
            BaseChartView(
                title: "Weight",
                subtitle: "Year",
                yDomain: minWeightValue()...maxWeightValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
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

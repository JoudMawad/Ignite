import SwiftUI
import Charts

struct MonthlyWeightChartView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
    }
    
    func maxWeightValue() -> Double {
        let maxWeight = formattedData.map { $0.weight }.filter { $0 > 0 }.max() ?? 100
        return maxWeight + 2
    }
    
    func minWeightValue() -> Double {
        let minWeight = formattedData.map { $0.weight }.filter { $0 > 0 }.min() ?? 50
        return minWeight - 2
    }
    
    var body: some View {
        ChartCardPinkView {
            BaseChartView(
                title: "Weight",
                subtitle: "Month",
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

struct MonthlyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyWeightChartView()
            .preferredColorScheme(.dark)
    }
}

import SwiftUI
import Charts

struct MonthlyWeightChartView: View {
    private let weightHistoryManager = WeightHistoryManager()
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 30, interval: 5, dateFormat: "MMM d")
    }

    /// ✅ Dynamically finds the max weight (adds a buffer)
    func maxWeightValue() -> Double {
        let maxWeight = formattedData.map { $0.weight }.filter { $0 > 0.0 }.max() ?? 100
        return maxWeight + 2 // Adds 2kg buffer for better visibility
    }

    /// ✅ Dynamically finds the min weight (adds a buffer)
    func minWeightValue() -> Double {
        let minWeight = formattedData.map { $0.weight }.filter { $0 > 0.0 }.min() ?? 50
        return minWeight - 2 // Adds 2kg buffer to prevent overlap
    }
    
    var body: some View {
        ChartCardPinkView {
            VStack {
                Text("Weight")
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
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.black)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: minWeightValue()...maxWeightValue()) // ✅ Uses new dynamic scaling
                .frame(height: 250)
                .padding()
            }
        }
    }
}

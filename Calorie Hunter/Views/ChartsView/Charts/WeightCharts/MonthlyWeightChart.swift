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

    func maxWeightValue() -> Double {
        return (formattedData.map { $0.weight }.max() ?? 100) + 1
    }
    
    var body: some View {
        ChartCardView {
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
                .chartYScale(domain: 0...maxWeightValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct MonthlyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = WeightHistoryManager()
        
        // ✅ Inject preview data
        previewManager.saveDailyWeight(currentWeight: 100.0)
        
        return MonthlyWeightChartView()
            .preferredColorScheme(.dark)
    }
}

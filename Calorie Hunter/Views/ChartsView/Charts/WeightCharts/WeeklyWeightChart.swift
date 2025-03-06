import SwiftUI
import Charts

struct WeeklyWeightChartView: View {
    private let weightHistoryManager = WeightHistoryManager()
    
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).compactMap { offset -> (String, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            
            let dateString = ChartDataHelper.dateToString(date)
            let weight = weightData.first(where: { $0.date == dateString })?.weight ?? 70.0 // Default if missing

            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"

            return (weekdayFormatter.string(from: date), weight)
        }.reversed()
    }
    
    func maxWeightValue() -> Double {
        let maxValue = formattedData.map { $0.weight }.max() ?? 100
        return maxValue + 1 // Add buffer
    }

    func minWeightValue() -> Double {
        let minValue = formattedData.map { $0.weight }.min() ?? 50
        return minValue - 1 // Add buffer
    }
    
    var body: some View {
        ChartCardPinkView {
            VStack {
                Text("Weight")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Week")
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
                .chartYScale(domain: minWeightValue()...maxWeightValue()) // ✅ FIXED SCALING
                .frame(height: 250)
                .padding()
            }
        }
    }
    
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        
        return allWeights
            .map { (ChartDataHelper.dateToString(ChartDataHelper.stringToDate($0.date)), $0.weight) }
    }
}

struct WeeklyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = WeightHistoryManager()
        
        // ✅ Inject preview data
        previewManager.saveDailyWeight(currentWeight: 80.0)
        
        return WeeklyWeightChartView()
            .preferredColorScheme(.dark)
    }
}

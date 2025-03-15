import SwiftUI
import Charts

struct YearlyWeightChartView: View {
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    // Retrieve stored weight data for the past 365 days.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    // Group the weight data into 90-day intervals.
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData,
                                        days: 365,
                                        interval: 90,
                                        outputDateFormat: "MMM yy")
    }
    
    func maxWeightValue() -> Double {
        (formattedData.map { $0.weight }.max() ?? 100) + 2
    }
    
    func minWeightValue() -> Double {
        (formattedData.map { $0.weight }.min() ?? 50) - 2
    }
    
    var body: some View {
        ChartCardPinkView {
            VStack {
                Text("Weight")
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
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, colorScheme == .dark ? Color.white : Color.black]),
                                startPoint: .top,
                                endPoint: .bottom)
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
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 51, 101, 151, 202, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 4, height: 21)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: minWeightValue()...maxWeightValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

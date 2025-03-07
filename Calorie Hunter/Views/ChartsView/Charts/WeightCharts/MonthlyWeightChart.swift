import SwiftUI
import Charts

struct MonthlyWeightChartView: View {
    private let weightHistoryManager = WeightHistoryManager()
    @State private var selectedOverlay: OverlayData?
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 30, interval: 5, dateFormat: "MMM d")
    }
    
    // Map formatted data into overlay data.
    var overlayData: [OverlayData] {
        formattedData.map { OverlayData(label: $0.label, value: $0.weight) }
    }
    
    // Dynamic Y-axis scaling.
    func maxWeightValue() -> Double {
        let maxWeight = formattedData.map { $0.weight }.filter { $0 > 0.0 }.max() ?? 100
        return maxWeight + 2
    }
    
    func minWeightValue() -> Double {
        let minWeight = formattedData.map { $0.weight }.filter { $0 > 0.0 }.min() ?? 50
        return minWeight - 2
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
                        .foregroundStyle(
                            LinearGradient(gradient: Gradient(colors: [.purple, .pink]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.black)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                // Example overlay for vertical grid lines.
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 42, 84, 126, 168, 210, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3.5, height: 21)
                                .foregroundColor(.black)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: minWeightValue()...maxWeightValue())
                // Use the reusable interactive overlay.
                .chartOverlay { proxy in
                    InteractiveChartOverlay(
                        proxy: proxy,
                        formattedData: overlayData,
                        selectedEntry: $selectedOverlay,
                        markerColor: .pink,            // Control marker color here.
                        labelColor: .black.opacity(0.8)   // Control label text color here.
                    )
                }
                .frame(height: 250)
                .padding()
            }
        }
    }
}

import SwiftUI
import Charts

struct YearlyWeightChartView: View {
    private let weightHistoryManager = WeightHistoryManager()
    @State private var selectedOverlay: OverlayData?
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 365, interval: 90, dateFormat: "MMM yy")
    }
    
    var overlayData: [OverlayData] {
        formattedData.map { OverlayData(label: $0.label, value: $0.weight) }
    }
    
    func maxWeightValue() -> Double {
        return (formattedData.map { $0.weight }.max() ?? 100) + 2
    }
    
    func minWeightValue() -> Double {
        return (formattedData.map { $0.weight }.min() ?? 50) - 2
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
                            LinearGradient(gradient: Gradient(colors: [.purple, .pink]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        if let plotAnchor = proxy.plotFrame {
                            let _ = geo[plotAnchor]
                            // Use the helper overlay.
                            InteractiveChartOverlay(
                                proxy: proxy,
                                formattedData: overlayData,
                                selectedEntry: $selectedOverlay,
                                markerColor: .pink,             // Customize as needed.
                                labelColor: .black.opacity(0.8)    // Customize as needed.
                            )
                        } else {
                            EmptyView()
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.black)
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
                                .foregroundColor(.black)
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

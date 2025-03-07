import SwiftUI
import Charts

struct YearlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    
    // State for interactive overlay.
    @State private var selectedOverlay: OverlayData?
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupData(from: calorieData, days: 365, interval: 90, dateFormat: "MMM yy")
    }
    
    // Map formatted data to overlay data.
    var overlayData: [OverlayData] {
        formattedData.map { OverlayData(label: $0.0, value: Double($0.1)) }
    }
    
    func maxCalorieValue() -> Int {
        return (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardCyanView {
            VStack {
                Text("Calories")
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
                            y: .value("Calories", entry.calories)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(gradient: Gradient(colors: [.blue, .cyan]),
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
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 51, 101, 151, 202, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3, height: 21)
                                .foregroundColor(.black)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: 0...maxCalorieValue())
                // Use the reusable interactive overlay.
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        if let _ = proxy.plotFrame {  // Ensures plot frame is available.
                            InteractiveChartOverlay(
                                proxy: proxy,
                                formattedData: overlayData,
                                selectedEntry: $selectedOverlay,
                                markerColor: .cyan,         // Customize marker color.
                                labelColor: .black.opacity(0.8) // Customize label text color.
                            )
                        } else {
                            EmptyView()
                        }
                    }
                }
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct YearlyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

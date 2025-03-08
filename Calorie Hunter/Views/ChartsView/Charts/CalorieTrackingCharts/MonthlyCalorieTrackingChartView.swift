import SwiftUI
import Charts

struct MonthlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    

    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupData(from: calorieData, days: 30, interval: 5, dateFormat: "MMM d")
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
                Text("Month")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(formattedData, id: \.0) { entry in
                        LineMark(
                            x: .value("Date", entry.0),
                            y: .value("Calories", entry.1)
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
                        let positions: [CGFloat] = [0, 42, 84, 126, 168, 210, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3, height: 21)
                                .foregroundColor(.black)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: 0...Double(maxCalorieValue()))

                .frame(height: 250)
                .padding()
            }
        }
    }
}

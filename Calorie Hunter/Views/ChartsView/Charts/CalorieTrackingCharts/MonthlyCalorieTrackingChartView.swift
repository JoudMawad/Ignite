import SwiftUI
import Charts

struct MonthlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    private let historyManager = CalorieHistoryManager()
    

    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: calorieData.map { (date: $0.date, value: Double($0.calories)) },
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
        .map { (label: $0.label, calories: Int($0.aggregatedValue)) }
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
                        AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
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
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
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

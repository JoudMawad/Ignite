import SwiftUI
import Charts

struct YearlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: calorieData.map { (date: $0.date, value: Double($0.calories)) },
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
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
                            LinearGradient(gradient: Gradient(colors: [.cyan, colorScheme == .dark ? Color.white : Color.black]),
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
                                .frame(width: 3, height: 21)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: 0...maxCalorieValue())
                // Use the reusable interactive overlay.
               
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

import SwiftUI
import Charts

struct WeeklyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        return (0..<7).map { offset -> (String, Int) in
            let date = calendar.date(byAdding: .day, value: -offset, to: yesterday)!
            let dateString = ChartDataHelper.dateToString(date)

            let calories = calorieData.first(where: { $0.date == dateString })?.calories ?? 0
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"

            return (weekdayFormatter.string(from: date), calories)
        }.reversed()
    }

    func maxCalorieValue() -> Int {
        return (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardView {
            VStack {
                Text("Calories")
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
                            y: .value("Calories", entry.calories)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine()
                                        .foregroundStyle(Color.black) // Makes vertical grid lines black
                                    AxisTick()
                                    AxisValueLabel()
                                }
                            }
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 36, 72, 108, 145, 180, 216, 253] // Control positions
                        
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 2, height: 21)
                                .foregroundColor(.black)
                                .blendMode(.normal) // Ensures black rendering
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: 0...maxCalorieValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct WeeklyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

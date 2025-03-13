import SwiftUI
import Charts

struct MonthlyBurnedCaloriesChartView: View {
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    /// Raw burned calories data for the past 30 days.
    private var burnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 30)
    }
    
    /// Group the 30 days into buckets of 5 days, labeling each bucket with "MMM d".
    private var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: burnedCaloriesData,
            days: 30,
            interval: 5,
            dateFormat: "MMM d"
        )
    }
    
    private func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Burned Calories")
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
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .pink]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
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
                .chartYScale(domain: 0...maxBurnedCaloriesValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

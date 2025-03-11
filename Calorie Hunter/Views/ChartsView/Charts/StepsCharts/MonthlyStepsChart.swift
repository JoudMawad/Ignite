import SwiftUI
import Charts

struct MonthlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    /// Raw step data for the past 30 days (now guaranteed to be 30 entries).
    private var stepData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 30)
    }
    
    /// Group the 30 days into buckets of 5 days, labeling each bucket with "MMM d".
    private var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: stepData,
            days: 30,
            interval: 5,
            dateFormat: "MMM d"
        )
    }
    
    private func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Steps")
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
                            y: .value("Steps", entry.steps)
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
                .chartYScale(domain: 0...Double(maxStepValue()))
                .frame(height: 250)
                .padding()
            }
        }
    }
}

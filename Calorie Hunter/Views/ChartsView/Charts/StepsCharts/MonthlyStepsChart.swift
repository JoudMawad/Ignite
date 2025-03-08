import SwiftUI
import Charts

struct MonthlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    
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
        ChartCardCyanView {
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
                        AxisGridLine().foregroundStyle(Color.black)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .overlay(
                    ZStack {
                        // Adjusted positions for ~6 data points in a 250pt wide chart
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
                .chartYScale(domain: 0...Double(maxStepValue()))
                .frame(height: 250)
                .padding()
            }
        }
    }
}

import SwiftUI
import Charts

struct YearlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    
    /// Last 365 days of raw step data.
    private var rawStepsData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 365)
    }
    
    /// Group into 90-day intervals, labeled "MMM yy".
    private var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: rawStepsData,
            days: 365,
            interval: 90,
            dateFormat: "MMM yy"
        )
    }
    
    private func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Steps")
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
                        AxisGridLine().foregroundStyle(.black)
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

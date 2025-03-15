import SwiftUI
import Charts

struct WeeklyStepsChartView: View {
    // This view uses the shared StepsHistoryManager as its data source.
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme

    // Create a local HealthKit steps manager.
    private let hkStepsManager = StepsManager()

    /// Grab the last 7 days of raw step data as (date: "yyyy-MM-dd", steps: Int) from the persistent history.
    private var rawStepsData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 7)
    }
    
    /// Use ChartDataHelper to group each day (interval=1).
    /// We'll label them with "EEE" (like "Mon", "Tue", etc.).
    private var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: rawStepsData,
            days: 7,
            interval: 1,
            outputDateFormat: "EEE"  // e.g. "Mon"
        )
    }
    
    /// A little headroom above the highest step count.
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
                
                Text("Week")
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
                                gradient: Gradient(colors: [.orange, colorScheme == .dark ? Color.white : Color.black]),
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

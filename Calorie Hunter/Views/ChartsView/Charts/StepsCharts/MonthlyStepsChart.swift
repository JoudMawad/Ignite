import SwiftUI
import Charts

struct MonthlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    var stepData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: stepData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
    }
    
    func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            BaseChartView(
                title: "Steps",
                subtitle: "Month",
                yDomain: 0...Double(maxStepValue()),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Steps", entry.steps)
                        )
                        .commonStyle(gradientColors: [.orange, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct MonthlyStepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyStepsChartView(stepsManager: StepsHistoryManager())
            .preferredColorScheme(.dark)
    }
}

import SwiftUI
import Charts

struct YearlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    var rawStepsData: [(date: String, steps: Int)] {
        stepsManager.stepsForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, steps: Int)] {
        ChartDataHelper.groupStepsData(
            from: rawStepsData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    func maxStepValue() -> Int {
        (formattedData.map { $0.steps }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardOrangeView {
            BaseChartView(
                title: "Steps",
                subtitle: "Year",
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

struct YearlyStepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyStepsChartView(stepsManager: StepsHistoryManager())
            .preferredColorScheme(.dark)
    }
}

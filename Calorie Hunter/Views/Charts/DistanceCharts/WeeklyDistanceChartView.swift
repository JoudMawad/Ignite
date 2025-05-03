import SwiftUI
import Charts

struct WeeklyDistanceChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme

    /// Raw distance data (meters) for the last 7 days.
    var rawDistanceData: [(date: String, distance: Double)] {
        stepsManager.distancesForPeriod(days: 7)
    }

    /// Group into daily buckets with abbreviated weekdays.
    var formattedData: [(label: String, distance: Double)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: rawDistanceData.map { (date: $0.date, value: $0.distance) },
            days: 7,
            interval: 1,
            outputDateFormat: "EEE"
        )
        .map { (label: $0.label, distance: $0.aggregatedValue) }
    }

    /// Returns the maximum distance in kilometers, with a 0.1 km buffer for headroom.
    func maxDistanceKmValue() -> Double {
        ((formattedData.map { $0.distance }.max() ?? 0) / 1000) + 0.1
    }

    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Distance",
                subtitle: "Week",
                yDomain: 0...maxDistanceKmValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Day", entry.label),
                            y: .value("Kilometers", entry.distance / 1000)
                        )
                        .commonStyle(
                            gradientColors: [
                                .blue,
                                colorScheme == .dark ? .white : .black
                            ]
                        )
                    }
                }
            )
            .chartYAxis {
                // Place 6 horizontal grid lines evenly spaced
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }
}

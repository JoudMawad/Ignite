import SwiftUI
import Charts

struct YearlyDistanceChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager
    @Environment(\.colorScheme) var colorScheme

    /// Raw distance data (meters) for the last 365 days.
    var rawDistanceData: [(date: String, distance: Double)] {
        stepsManager.distancesForPeriod(days: 365)
    }

    /// Group into 90-day buckets, label by “MMM yy”.
    var formattedData: [(label: String, distance: Double)] {
        ChartDataHelper.groupDataIncludingZeros(
            from: rawDistanceData.map { (date: $0.date, value: $0.distance) },
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
        .map { (label: $0.label, distance: $0.aggregatedValue) }
    }

    /// Returns the maximum distance in kilometers, with a 1 km buffer for headroom.
    func maxDistanceKmValue() -> Double {
        ((formattedData.map { $0.distance }.max() ?? 0) / 1000) + 1.0
    }

    var body: some View {
        ChartCardCyanView {
            BaseChartView(
                title: "Distance",
                subtitle: "Year",
                yDomain: 0...maxDistanceKmValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
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
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }
}

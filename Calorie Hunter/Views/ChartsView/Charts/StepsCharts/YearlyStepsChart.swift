import SwiftUI
import Charts

struct YearlyStepsChartView: View {
    @ObservedObject var stepsManager: StepsHistoryManager

    /// Returns the last 365 days of steps, in ascending date order.
    private var stepsData: [(date: Date, steps: Int)] {
        // 1) Grab the raw dictionary data from StepsHistoryManager (as (String, Int))
        let raw = stepsManager.stepsForPeriod(days: 365)

        // 2) Convert "yyyy-MM-dd" -> Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // 3) Map to (Date, Int). If parsing fails, skip the record.
        let parsed: [(date: Date, steps: Int)] = raw.compactMap { tuple in
            guard let parsedDate = formatter.date(from: tuple.date) else { return nil }
            return (parsedDate, tuple.steps)
        }
        // 4) Sort by ascending date, in case `stepsForPeriod` returns them in reverse.
        .sorted { $0.date < $1.date }

        return parsed
    }

    var body: some View {
        VStack {
            Text("Steps Over the Last Year")
                .font(.headline)
                .padding(.bottom, 4)

            // A button to show data in Xcode’s console for debugging
            Button("Print Debug Info") {
                print("stepsData count: \(stepsData.count)")
                for (idx, entry) in stepsData.enumerated() {
                    print("\(idx). date = \(entry.date), steps = \(entry.steps)")
                }
            }
            .padding(.bottom, 8)

            Chart {
                ForEach(stepsData, id: \.date) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Steps", entry.steps)
                    )
                    // If you like, set interpolation
                    .interpolationMethod(.monotone)
                }
            }
            // Force a domain so you can see if the data is near zero or extremely high.
            .chartYScale(domain: 0...20000)
            .frame(height: 300)
            .padding()
        }
    }
}

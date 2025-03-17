import SwiftUI
import Charts

struct BaseChartView<Content: ChartContent>: View {
    let title: String
    let subtitle: String
    let yDomain: ClosedRange<Double>
    let chartContent: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Text(subtitle)
                .font(.system(size: 18, weight: .light, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Chart {
                chartContent()
            }
            .applyChartAxisStyle()
            .chartYScale(domain: yDomain)
            .frame(height: 250)
            .padding()
        }
    }
}

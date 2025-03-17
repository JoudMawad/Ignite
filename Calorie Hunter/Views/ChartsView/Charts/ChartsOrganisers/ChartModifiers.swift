import SwiftUI
import Charts

extension LineMark {
    func commonStyle(gradientColors: [Color]) -> some ChartContent {
        self
            .interpolationMethod(.monotone)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .symbol(Circle())
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

struct ChartAxisModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                AxisTick()
                AxisValueLabel()
            }
        }
    }
}

extension View {
    func applyChartAxisStyle() -> some View {
        self.modifier(ChartAxisModifier())
    }
}

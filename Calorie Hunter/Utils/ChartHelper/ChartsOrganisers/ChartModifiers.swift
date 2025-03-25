import SwiftUI
import Charts

// This extension adds a common styling method to LineMark,
// which is useful for applying a consistent look across multiple charts.
extension LineMark {
    /// Applies a common style to the line mark using a gradient.
    /// - Parameter gradientColors: The colors used to create the gradient for the line.
    /// - Returns: A ChartContent view with the styling applied.
    func commonStyle(gradientColors: [Color]) -> some ChartContent {
        self
            // Use a smooth curve between data points.
            .interpolationMethod(.monotone)
            // Set the line width for better visibility.
            .lineStyle(StrokeStyle(lineWidth: 3))
            // Add a circle symbol at each data point.
            .symbol(Circle())
            // Apply a linear gradient as the foreground style.
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// This view modifier customizes the appearance of chart axes.
struct ChartAxisModifier: ViewModifier {
    // Access the current color scheme (light or dark) to adjust styling accordingly.
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.chartXAxis {
            // Define axis marks automatically.
            AxisMarks(values: .automatic) { _ in
                // Set the grid line color depending on the color scheme.
                AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                // Add ticks to the axis.
                AxisTick()
                // Add labels to the axis values.
                AxisValueLabel()
            }
        }
    }
}

// This extension makes it easier to apply our chart axis style to any view.
extension View {
    /// Applies a custom style to the chart's x-axis.
    /// - Returns: A view with the chart axis style modifier applied.
    func applyChartAxisStyle() -> some View {
        self.modifier(ChartAxisModifier())
    }
}

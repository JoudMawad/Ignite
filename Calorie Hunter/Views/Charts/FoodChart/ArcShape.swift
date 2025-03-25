import SwiftUI

/// A custom shape that draws an arc with a specified start and end angle,
/// along with a defined line width.
struct ArcShape: Shape {
    // Starting angle of the arc.
    var startAngle: Angle
    // Ending angle of the arc.
    var endAngle: Angle
    // Thickness of the arc's stroke.
    var lineWidth: CGFloat

    /// Creates a path for the arc within the given rectangle.
    /// - Parameter rect: The bounding rectangle in which the arc is drawn.
    /// - Returns: A stroked path representing the arc.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Calculate the radius as half the smallest dimension, subtracting half the line width
        // to ensure the stroke is drawn completely inside the view's bounds.
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        
        // Determine the center point of the rectangle.
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Add an arc to the path using the computed center, radius, start angle, and end angle.
        // The arc is drawn in a counter-clockwise direction (clockwise: false).
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        // Return the path as a stroked path using a StrokeStyle that specifies the line width
        // and a rounded line cap for smooth endpoints.
        return path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}

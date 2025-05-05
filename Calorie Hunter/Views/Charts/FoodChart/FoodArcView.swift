import SwiftUI

struct FoodArcView: View {
    // Access the current color scheme for adaptive gradient colors.
    @Environment(\.colorScheme) var colorScheme
    // Start and end angles defining the arc segment.
    var startAngle: Angle
    var endAngle: Angle
    // Thickness of the arc stroke.
    var lineWidth: CGFloat
    // Nutrient name (e.g., "Protein", "Carbs", "Fat") determines gradient colors.
    var nutrientName: String

    var body: some View {
        // Calculate the angular span of the arc.
        let arcAngle = endAngle.degrees - startAngle.degrees
        
        // Draw the arc shape using our custom ArcShape.
        ArcShape(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
            // Overlay an AngularGradient that only covers the length of the arc.
            .overlay {
                AngularGradient(
                    gradient: Gradient(colors: gradientFor(nutrient: nutrientName)),
                    center: .center,
                    // The gradient spans the arcAngle; 0° here aligns with the arc's start.
                    startAngle: .degrees(0),
                    endAngle: .degrees(arcAngle)
                )
                // Rotate the gradient so that it aligns with the arc's starting angle.
                .rotationEffect(startAngle)
            }
            // Mask the gradient to the shape of the arc.
            .mask {
                ArcShape(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
            }
    }
    
    /// Returns an array of colors for the nutrient gradient.
    /// Colors are chosen based on the nutrient and adapted to the current color scheme.
    private func gradientFor(nutrient: String) -> [Color] {

        let darkGreen2 = Color(red: 0, green: 0.8, blue: 0)
        
        // Select gradient colors based on the nutrient type and current color scheme.
        switch nutrient {
        case "Protein":
            return [.pink, .purple, .pink]
        case "Carbs":
            return [.blue, .cyan, .blue]
        case "Fat":
            return [.green, darkGreen2, .green]
        default:
            return [Color.gray]
        }
    }
}

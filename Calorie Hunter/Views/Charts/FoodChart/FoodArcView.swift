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
        // Define dark and light variations for red, blue, and green.
        let darkRed = Color(red: 0.6, green: 0, blue: 0)
        let darkRed1 = Color(red: 0.3, green: 0, blue: 0)
        let darkBlue = Color(red: 0, green: 0, blue: 0.6)
        let darkBlue1 = Color(red: 0, green: 0, blue: 0.3)
        let darkGreen = Color(red: 0, green: 0.6, blue: 0)
        let darkGreen1 = Color(red: 0, green: 0.3, blue: 0)
        let lightRed = Color(red: 1.3, green: 0, blue: 0)
        let lightRed1 = Color(red: 1.5, green: 0, blue: 0)
        let lightBlue = Color(red: 0, green: 0, blue: 1.8)
        let lightBlue1 = Color(red: 0, green: 0, blue: 2.0)
        let lightGreen = Color(red: 0, green: 1.2, blue: 0)
        let lightGreen1 = Color(red: 0, green: 1, blue: 0)
        
        // Select gradient colors based on the nutrient type and current color scheme.
        switch nutrient {
        case "Protein":
            return colorScheme == .light
                ? [lightRed1, lightRed, lightRed1]
                : [darkRed1, darkRed, darkRed1]
        case "Carbs":
            return colorScheme == .light
                ? [lightGreen, lightGreen1, lightGreen]
                : [darkGreen1, darkGreen, darkGreen1]
        case "Fat":
            return colorScheme == .light
                ? [lightBlue1, lightBlue, lightBlue1]
                : [darkBlue1, darkBlue, darkBlue1]
        default:
            return [Color.gray]
        }
    }
}

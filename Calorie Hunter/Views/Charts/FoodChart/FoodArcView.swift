import SwiftUI

struct FoodArcView: View {
    @Environment(\.colorScheme) var colorScheme
    var startAngle: Angle
    var endAngle: Angle
    var lineWidth: CGFloat
    var nutrientName: String

    var body: some View {
        // Calculate the angular span of the arc.
        let arcAngle = endAngle.degrees - startAngle.degrees
        


        ArcShape(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
            .overlay {
                // Create an AngularGradient that spans only the arc's length,
                // then rotate it so its 0° aligns with the arc's start.
                AngularGradient(
                    gradient: Gradient(colors: gradientFor(nutrient: nutrientName)),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(arcAngle)
                )
                .rotationEffect(startAngle)
            }
            .mask {
                ArcShape(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
            }
    }
    
    private func gradientFor(nutrient: String) -> [Color] {
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

import SwiftUI

struct FoodChartView: View {
    @Environment(\.colorScheme) var colorScheme
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let totalAmount = totalProtein + totalCarbs + totalFat
            
            // Calculate fractions for each nutrient.
            let proteinFraction = totalProtein / totalAmount
            let carbsFraction = totalCarbs / totalAmount
            let fatFraction = totalFat / totalAmount

            // Define a gap (in degrees) between arcs.
            let gapDegrees = 5.0   // Adjust the gap size as needed.
            let numberOfArcs = 3.0
            let totalGap = gapDegrees * numberOfArcs
            let availableDegrees = 360.0 - totalGap
            
            // Calculate the angle for each nutrient using available degrees.
            let proteinAngleDegrees = availableDegrees * proteinFraction
            let carbsAngleDegrees = availableDegrees * carbsFraction
            let fatAngleDegrees = availableDegrees * fatFraction

            // Calculate start and end angles with gaps between them.
            let proteinStart = Angle.degrees(0)
            let proteinEnd = Angle.degrees(proteinAngleDegrees)
            
            let carbsStart = Angle.degrees(proteinAngleDegrees + gapDegrees)
            let carbsEnd = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees)
            
            let fatStart = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees + gapDegrees)
            let fatEnd = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees + gapDegrees + fatAngleDegrees)
            
            ZStack {
                // Outer glow effect.
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: size * 0.034)
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.03)

                // Draw each nutrient arc.
                FoodArcView(
                    startAngle: proteinStart,
                    endAngle: proteinEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Protein"
                )
                .frame(width: size, height: size)
                
                FoodArcView(
                    startAngle: carbsStart,
                    endAngle: carbsEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Carbs"
                )
                .frame(width: size, height: size)
                
                FoodArcView(
                    startAngle: fatStart,
                    endAngle: fatEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Fat"
                )
                .frame(width: size, height: size)
                
                // Center view displaying macro breakdown.
                VStack(spacing: size * 0.05) {
                    MacroRowView(
                        title: "Protein",
                        value: totalProtein,
                        percentage: proteinFraction * 100
                    )
                    MacroRowView(
                        title: "Carbs",
                        value: totalCarbs,
                        percentage: carbsFraction * 100
                    )
                    MacroRowView(
                        title: "Fat",
                        value: totalFat,
                        percentage: fatFraction * 100
                    )
                }
                .font(.system(size: size * 0.08))
                .foregroundColor(.white)
                .padding(size * 0.05)
            }
        }
    }
}

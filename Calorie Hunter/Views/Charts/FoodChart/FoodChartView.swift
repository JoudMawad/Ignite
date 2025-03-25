import SwiftUI

struct FoodChartView: View {
    // Adapts UI styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    // Total nutrient amounts (in grams or calories, as defined elsewhere).
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    var body: some View {
        GeometryReader { geometry in
            // Use the smaller of the width or height to maintain a circular layout.
            let size = min(geometry.size.width, geometry.size.height)
            // Calculate the total amount of all nutrients combined.
            let totalAmount = totalProtein + totalCarbs + totalFat
            
            // Compute the fraction for each nutrient.
            let proteinFraction = totalProtein / totalAmount
            let carbsFraction = totalCarbs / totalAmount
            let fatFraction = totalFat / totalAmount

            // Define a small gap (in degrees) to visually separate the arcs.
            let gapDegrees = 5.0   // Adjust gap size as needed.
            let numberOfArcs = 3.0
            // Total gap allocated across all arcs.
            let totalGap = gapDegrees * numberOfArcs
            // Calculate available degrees for nutrient arcs (full circle minus gaps).
            let availableDegrees = 360.0 - totalGap
            
            // Calculate the angular span for each nutrient.
            let proteinAngleDegrees = availableDegrees * proteinFraction
            let carbsAngleDegrees = availableDegrees * carbsFraction
            let fatAngleDegrees = availableDegrees * fatFraction

            // Define start and end angles for each nutrient arc, including gaps.
            let proteinStart = Angle.degrees(0)
            let proteinEnd = Angle.degrees(proteinAngleDegrees)
            
            let carbsStart = Angle.degrees(proteinAngleDegrees + gapDegrees)
            let carbsEnd = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees)
            
            let fatStart = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees + gapDegrees)
            let fatEnd = Angle.degrees(proteinAngleDegrees + gapDegrees + carbsAngleDegrees + gapDegrees + fatAngleDegrees)
            
            ZStack {
                // Draw an outer circle with a glow effect for visual depth.
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: size * 0.034)
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.03)

                // Draw the Protein arc using FoodArcView.
                FoodArcView(
                    startAngle: proteinStart,
                    endAngle: proteinEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Protein"
                )
                .frame(width: size, height: size)
                
                // Draw the Carbs arc using FoodArcView.
                FoodArcView(
                    startAngle: carbsStart,
                    endAngle: carbsEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Carbs"
                )
                .frame(width: size, height: size)
                
                // Draw the Fat arc using FoodArcView.
                FoodArcView(
                    startAngle: fatStart,
                    endAngle: fatEnd,
                    lineWidth: size * 0.034,
                    nutrientName: "Fat"
                )
                .frame(width: size, height: size)
                
                // Centered view showing the macro breakdown.
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
                // Scale the font size relative to the available size.
                .font(.system(size: size * 0.08))
                .foregroundColor(.white)
                .padding(size * 0.05)
            }
        }
    }
}

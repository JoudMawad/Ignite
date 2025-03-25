import SwiftUI

struct MacroRowView: View {
    // Adapt the view's colors based on the system's light or dark mode.
    @Environment(\.colorScheme) var colorScheme
    // Nutrient name, e.g., "Protein", "Carbs", or "Fat".
    let title: String
    // The total amount of this nutrient.
    let value: Double
    // The percentage that this nutrient represents in the overall breakdown.
    let percentage: Double
    
    var body: some View {
        // Retrieve a gradient array based on the nutrient type and current color scheme.
        // Use the first color in the gradient as the single indicator color.
        let colors = ChartGradientHelper.gradientForNutrient(title, colorScheme: colorScheme)
        let indicatorColor: Color = colors.first ?? Color.blue

        return HStack {
            // A small circle used as a color indicator for the nutrient.
            Circle()
                .fill(indicatorColor)
                .frame(width: 12, height: 12)
            
            // Display the nutrient name and its value, converting the value to an integer.
            Text("\(title): \(Int(value))g ")
                .foregroundColor(colorScheme == .dark ? .black : .white)
        }
    }
}

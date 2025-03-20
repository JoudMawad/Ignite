import SwiftUI

struct MacroRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: Double
    let percentage: Double
    
    var body: some View {
        // Retrieve the colors and use just one for the indicator.
        let colors = ChartGradientHelper.gradientForNutrient(title, colorScheme: colorScheme)
        let indicatorColor: Color = colors.first ?? Color.blue

        return HStack {
            // Single Color Indicator
            Circle()
                .fill(indicatorColor)
                .frame(width: 12, height: 12)
            
            Text("\(title): \(Int(value))g ")
                .foregroundColor(colorScheme == .dark ? .black : .white)
        }
    }
}

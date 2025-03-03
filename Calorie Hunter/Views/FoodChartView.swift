import SwiftUI
import Charts

struct FoodChartView: View {
    @Environment(\.colorScheme) var colorScheme
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    var body: some View {
        let isEmpty = (totalProtein == 0 && totalCarbs == 0 && totalFat == 0)

        let nutrients: [Nutrient] = isEmpty ? [
            Nutrient(name: "Empty", amount: 1, color: .gray.opacity(0.3)) // ✅ Placeholder chart
        ] : [
            Nutrient(name: "Protein", amount: totalProtein, color: .blue.opacity(0.9)),
            Nutrient(name: "Carbs", amount: totalCarbs, color: .green.opacity(0.9)),
            Nutrient(name: "Fat", amount: totalFat, color: .red.opacity(0.9))
        ]

        ZStack {
                       // ✅ Outer Neon Glow following the Chart Color Segments
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.6),
                        ]),
                        center: .center
                    ),
                    lineWidth: 12
                )
                .frame(width: 305, height: 305)
                .blur(radius: 10) // ✅ Outer neon glow

            // ✅ Pie Chart
            Chart {
                ForEach(nutrients) { nutrient in
                    SectorMark(
                        angle: .value("Amount", nutrient.amount),
                        innerRadius: .ratio(0.95), // ✅ Thinner ring
                        angularInset: 1.5
                    )
                    .foregroundStyle(nutrient.color)
                    .cornerRadius(6)
                }
            }
            .frame(height: 300)
            .rotationEffect(.degrees(90)) // ✅ Ensures visual consistency
            .clipShape(Rectangle().offset(y: 0))

            // ✅ Macro Breakdown Inside the Circle with Neon Glow
            VStack(spacing: 6) {
                macroRow(title: "Protein", value: totalProtein, color: .blue)
                macroRow(title: "Carbs", value: totalCarbs, color: .green)
                macroRow(title: "Fat", value: totalFat, color: .red)
            }
            .font(.headline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
        }
    }

    // ✅ Helper Function to Create Each Macro Row with Neon Glow
    private func macroRow(title: String, value: Double, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 3) // ✅ Stronger glow
                        .blur(radius: 6) // ✅ Enhances the neon effect
                        .opacity(0.9)
                )
            Text("\(title): \(Int(value))g")
        }
    }
}

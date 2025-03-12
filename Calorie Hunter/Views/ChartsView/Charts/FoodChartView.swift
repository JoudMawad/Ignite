import SwiftUI
import Charts

struct FoodChartView: View {
    @Environment(\.colorScheme) var colorScheme
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    
    var body: some View {
        GeometryReader { geometry in
            // Use the smaller of width/height to define our base size.
            let size = min(geometry.size.width, geometry.size.height)
            
            let nutrients: [Nutrient] = [
                Nutrient(name: "Protein", amount: totalProtein, color: .blue.opacity(0.9)),
                Nutrient(name: "Carbs", amount: totalCarbs, color: .green.opacity(0.9)),
                Nutrient(name: "Fat", amount: totalFat, color: .cyan.opacity(0.9))
            ]
            
            let totalAmount = totalProtein + totalCarbs + totalFat
            
            ZStack {
                // Outer glow effect around the chart.
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: size * 0.034)
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.03)
                
                // Pie chart using the Chart view.
                Chart {
                    let angles = ChartGradientHelper.startEndAngles(nutrients: nutrients)
                    ForEach(nutrients) { nutrient in
                        if let (startAngle, endAngle) = angles[nutrient.name] {
                            SectorMark(
                                angle: .value("Amount", nutrient.amount),
                                innerRadius: .ratio(0.95),
                                angularInset: 1.5
                            )
                            .foregroundStyle(
                                AngularGradient(
                                    gradient: Gradient(colors: ChartGradientHelper.gradientForNutrient(nutrient.name)),
                                    center: .center,
                                    startAngle: .degrees(startAngle),
                                    endAngle: .degrees(endAngle)
                                )
                            )
                            .cornerRadius(6)
                        }
                    }
                }
                .frame(height: size)
                .rotationEffect(.degrees(90))
                
                // Macro breakdown info displayed in the center.
                VStack(spacing: size * 0.05) {
                    ForEach(nutrients) { nutrient in
                        MacroRowView(
                            title: nutrient.name,
                            value: nutrient.amount,
                            percentage: (nutrient.amount / totalAmount) * 100
                        )
                    }
                }
                .font(.system(size: size * 0.08))
                .foregroundColor(.white)
                .padding(size * 0.05)
            }
            .animation(.easeInOut(duration: 0.5), value: totalAmount)
        }
        // Remove any fixed frame here so that the parent view (HomeView) can control the size.
    }
}

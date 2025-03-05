//
//  FoodChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

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
            Nutrient(name: "Empty", amount: 1, color: .gray.opacity(0.3))
        ] : [
            Nutrient(name: "Protein", amount: totalProtein, color: .blue.opacity(0.9)),
            Nutrient(name: "Carbs", amount: totalCarbs, color: .green.opacity(0.9)),
            Nutrient(name: "Fat", amount: totalFat, color: .cyan.opacity(0.9))
        ]
        
        let totalAmount = totalProtein + totalCarbs + totalFat
        
        ZStack {
            // Outer Glow Effect
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.4)]),
                        center: .center
                    ),
                    lineWidth: 12
                )
                .frame(width: 305, height: 305)
                .blur(radius: 10)
                .shadow(color: .gray.opacity(0.3), radius: 10)
            
            // Pie Chart
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
            .frame(height: 300)
            .rotationEffect(.degrees(90))
            
            // Macro Breakdown
            VStack(spacing: 6) {
                ForEach(nutrients) { nutrient in
                    if nutrient.name != "Empty" {
                        MacroRowView(title: nutrient.name, value: nutrient.amount, percentage: (nutrient.amount / totalAmount) * 100)
                    }
                }
            }
            .font(.headline)
            .foregroundColor(.primary)
            .padding()
        }
        .animation(.easeInOut(duration: 0.5), value: totalAmount)
    }
}

// MARK: - Preview
struct FoodChartView_Previews: PreviewProvider {
    static var previews: some View {
        FoodChartView(totalProtein: 200, totalCarbs: 160, totalFat: 160)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(UIColor.systemBackground))
    }
}

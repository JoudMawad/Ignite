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
        
        let nutrients: [Nutrient] = [
            Nutrient(name: "Protein", amount: totalProtein, color: .blue.opacity(0.9)),
            Nutrient(name: "Carbs", amount: totalCarbs, color: .green.opacity(0.9)),
            Nutrient(name: "Fat", amount: totalFat, color: .cyan.opacity(0.9))
        ]
        
        let totalAmount = totalProtein + totalCarbs + totalFat
        
        ZStack {
            // Outer Glow Effect
            Circle()
                .stroke(Color.gray.opacity(0.45), lineWidth: 10)
                .frame(width: 290, height: 290)
                .blur(radius: 8)
            
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
                        MacroRowView(title: nutrient.name, value: nutrient.amount, percentage: (nutrient.amount / totalAmount) * 100)
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

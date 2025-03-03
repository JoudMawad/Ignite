//
//  FoodChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//

import SwiftUI
import Charts

struct FoodChartView: View {
    @Environment(\.colorScheme) var colorScheme
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    var body: some View {
        let nutrients = [
            Nutrient(name: "Protein", amount: totalProtein, color: .primary.opacity(0.5)),
            Nutrient(name: "Carbs", amount: totalCarbs, color: .primary.opacity(0.7)),
            Nutrient(name: "Fat", amount: totalFat, color: .primary.opacity(0.9))
        ]

        VStack {
            Chart {
                ForEach(nutrients) { nutrient in
                    SectorMark(
                        angle: .value("Amount", nutrient.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(nutrient.color)
                }
            }
            .frame(height: 300) // Increase height to allow clipping
            .rotationEffect(.degrees(90)) // Rotate chart to start from the bottom
            .clipShape(Rectangle().offset(y: 0))
        }
    }
}


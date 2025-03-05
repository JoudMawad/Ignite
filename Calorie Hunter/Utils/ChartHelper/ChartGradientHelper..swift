//
//  ChartGradientHelper.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

struct ChartGradientHelper {
    
    // Gradient colors for each nutrient
    static func gradientForNutrient(_ name: String) -> [Color] {
        switch name.lowercased() {
        case "protein":
            return [Color.purple.opacity(1), Color.purple.opacity(1.3)]
        case "carbs":
            return [Color.pink.opacity(1), Color.pink.opacity(1.3)]
        case "fat":
            return [Color.blue.opacity(1), Color.blue.opacity(1.3)]
        default:
            return [Color.gray.opacity(0.3)]
        }
    }

    // Compute start and end angles for each nutrient segment
    static func startEndAngles(nutrients: [Nutrient]) -> [String: (Double, Double)] {
        var angles: [String: (Double, Double)] = [:]
        let totalAmount = nutrients.reduce(0) { $0 + $1.amount }
        guard totalAmount > 0 else { return angles }

        var currentAngle: Double = 0
        let sortedNutrients = nutrients.sorted { $0.amount > $1.amount }

        for nutrient in sortedNutrients {
            let proportion = nutrient.amount / totalAmount
            let startAngle = currentAngle
            let endAngle = startAngle + (proportion * 360)
            angles[nutrient.name] = (startAngle, endAngle)
            currentAngle = endAngle
        }

        return angles
    }
}

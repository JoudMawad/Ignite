//
//  ChartGradientHelper.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

import SwiftUI

struct ChartGradientHelper {
    
    /// Returns an array of colors for the given nutrient name, using the provided color scheme.
    static func gradientForNutrient(_ name: String, colorScheme: ColorScheme) -> [Color] {
        // Define colors within proper ranges (0...1).
        let darkRed = Color(red: 0.6, green: 0, blue: 0)
        let darkBlue = Color(red: 0, green: 0, blue: 0.6)
        let darkGreen = Color(red: 0, green: 0.6, blue: 0)
        
        let lightRed = Color(red: 1, green: 0, blue: 0)
        let lightBlue = Color(red: 0, green: 0, blue: 1)
        let lightGreen = Color(red: 0, green: 1, blue: 0)
        
        switch name.lowercased() {
        case "protein":
            return colorScheme == .light ? [lightRed] : [darkRed]
        case "carbs":
            // Using two identical colors for demonstration. Adjust as needed.
            return colorScheme == .light ? [lightGreen] : [darkGreen]
        case "fat":
            return colorScheme == .light ? [lightBlue] : [darkBlue]
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

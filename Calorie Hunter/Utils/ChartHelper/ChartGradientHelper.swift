//
//  ChartGradientHelper.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

// ChartGradientHelper is a utility struct for handling chart gradient colors
// and calculating segment angles for nutrient charts.
struct ChartGradientHelper {
    
    /// Returns an array of colors for a given nutrient, based on the current color scheme.
    ///
    /// This function defines different colors for nutrients like protein, carbs, and fat.
    /// It returns a light or dark color variant depending on whether the app is in light or dark mode.
    ///
    /// - Parameters:
    ///   - name: The name of the nutrient (e.g., "protein", "carbs", or "fat").
    ///   - colorScheme: The current color scheme of the app.
    /// - Returns: An array of Color values used to create a gradient.
    static func gradientForNutrient(_ name: String, colorScheme: ColorScheme) -> [Color] {
        // Define dark color variants.
        let darkRed = Color(red: 0.6, green: 0, blue: 0)
        let darkBlue = Color(red: 0, green: 0, blue: 0.6)
        let darkGreen = Color(red: 0, green: 0.6, blue: 0)
        
        // Define light color variants.
        let lightRed = Color(red: 1, green: 0, blue: 0)
        let lightBlue = Color(red: 0, green: 0, blue: 1)
        let lightGreen = Color(red: 0, green: 1, blue: 0)
        
        // Return the appropriate gradient based on the nutrient name and color scheme.
        switch name.lowercased() {
        case "protein":
            return colorScheme == .light ? [lightRed] : [darkRed]
        case "carbs":
            // Currently using a single color for carbs; adjust as needed for more complex gradients.
            return colorScheme == .light ? [lightGreen] : [darkGreen]
        case "fat":
            return colorScheme == .light ? [lightBlue] : [darkBlue]
        default:
            // Return a default light gray gradient if the nutrient doesn't match known names.
            return [Color.gray.opacity(0.3)]
        }
    }

    /// Computes the start and end angles (in degrees) for each nutrient segment.
    ///
    /// This function calculates the angle range each nutrient occupies in a circular chart.
    /// It does so by computing the proportion of each nutrient's amount relative to the total,
    /// then mapping that proportion to a full circle (360 degrees).
    ///
    /// - Parameter nutrients: An array of Nutrient objects, each with a name and an amount.
    /// - Returns: A dictionary mapping each nutrient's name to a tuple containing its start and end angles.
    static func startEndAngles(nutrients: [Nutrient]) -> [String: (Double, Double)] {
        var angles: [String: (Double, Double)] = [:]
        // Sum up the total amount across all nutrients.
        let totalAmount = nutrients.reduce(0) { $0 + $1.amount }
        // If there's no data, return an empty dictionary.
        guard totalAmount > 0 else { return angles }

        var currentAngle: Double = 0
        // Sort nutrients in descending order by amount for consistent ordering.
        let sortedNutrients = nutrients.sorted { $0.amount > $1.amount }

        // For each nutrient, calculate its proportion of the total and convert that to an angle.
        for nutrient in sortedNutrients {
            let proportion = nutrient.amount / totalAmount
            let startAngle = currentAngle
            let endAngle = startAngle + (proportion * 360)
            angles[nutrient.name] = (startAngle, endAngle)
            // Update currentAngle for the next nutrient segment.
            currentAngle = endAngle
        }

        return angles
    }
}

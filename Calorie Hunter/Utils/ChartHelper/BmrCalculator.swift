//
//  BmrCalculator.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 08.03.25.
//

import Foundation

// BMRCalculator is a utility struct that calculates the Basal Metabolic Rate (BMR)
// using the Harris–Benedict formula, which estimates the number of calories required
// to maintain basic bodily functions at rest.
struct BMRCalculator {
    /// Computes the Basal Metabolic Rate (BMR) using the Harris–Benedict formula.
    /// - Parameters:
    ///   - weight: The weight in kilograms.
    ///   - age: The age in years.
    ///   - height: The height in centimeters.
    ///   - gender: The gender as a String ("male" or "female").
    /// - Returns: The computed BMR value.
    static func computeBMR(forWeight weight: Double, age: Double, height: Double, gender: String) -> Double {
        // If the gender is male, use the male formula.
        if gender.lowercased() == "male" {
            return (10 * weight) + (6.25 * height) - (5 * age) + 5
        } else {
            // Otherwise, assume female and use the female formula.
            return (10 * weight) + (6.25 * height) - (5 * age) - 161
        }
    }
}

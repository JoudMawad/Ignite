//
//  BmrCalculator.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 08.03.25.
//

import Foundation

struct BMRCalculator {
    /// Computes the Basal Metabolic Rate (BMR) using the Harris–Benedict formula.
    /// - Parameters:
    ///   - weight: The weight in kilograms.
    ///   - age: The age in years.
    ///   - height: The height in centimeters.
    ///   - gender: The gender as a String ("male" or "female").
    /// - Returns: The computed BMR value.
    static func computeBMR(forWeight weight: Double, age: Double, height: Double, gender: String) -> Double {
        if gender.lowercased() == "male" {
            return (10 * weight) + (6.25 * height) - (5 * age) + 5
        } else {
            return (10 * weight) + (6.25 * height) - (5 * age) - 161
        }
    }
}

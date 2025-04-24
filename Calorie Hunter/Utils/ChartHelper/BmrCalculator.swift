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
    static func computeBMR(
        forWeight weight: Double,
        age: Double,
        height: Double,
        gender: String
    ) -> Double {
        // 1) Cast height to Double once
        let h = Double(height)
        
        // 2) Compute each term separately
        let weightTerm = 10.0 * weight          // 10 × weight
        let heightTerm = 6.25 * h               // 6.25 × height
        let ageTerm    = 5.0  * age             // 5 × age
        
        // 3) Combine with the gender‐specific constant
        if gender.lowercased() == "male" {
            // male formula: +5
            return weightTerm + heightTerm - ageTerm + 5.0
        } else {
            // female formula: -161
            return weightTerm + heightTerm - ageTerm - 161.0
        }
    }
}

//
//  Nutrient.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//
import SwiftUI

struct Nutrient: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var color: Color
}


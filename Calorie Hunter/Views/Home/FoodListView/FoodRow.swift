//
//  FoodRow.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//

import SwiftUI

struct FoodRow: View {
    let food: FoodItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(food.name).font(.headline)
                Text("\(food.calories) kcal").foregroundColor(.gray)
            }
            Spacer()
            Text("P: \(food.protein, specifier: "%.0f")g  C: \(food.carbs, specifier: "%.0f")g  F: \(food.fat, specifier: "%.0f")g")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

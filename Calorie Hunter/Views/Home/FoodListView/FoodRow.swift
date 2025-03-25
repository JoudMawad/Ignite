import SwiftUI

struct FoodRow: View {
    // The food item to be displayed.
    let food: FoodItem
    
    var body: some View {
        // Horizontal stack for organizing food details.
        HStack {
            // VStack to align the food name and calorie info vertically.
            VStack(alignment: .leading) {
                // Display the food name with a headline font.
                Text(food.name)
                    .font(.headline)
                // Display the calorie count in gray to denote secondary information.
                Text("\(food.calories) kcal")
                    .foregroundColor(.gray)
            }
            Spacer()
            // Display macronutrient breakdown with a smaller caption font.
            Text("P: \(food.protein, specifier: "%.0f")g  C: \(food.carbs, specifier: "%.0f")g  F: \(food.fat, specifier: "%.0f")g")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        // Vertical padding to provide spacing between rows.
        .padding(.vertical, 5)
    }
}

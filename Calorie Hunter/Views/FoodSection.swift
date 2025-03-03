//
//  FoodSection.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//

import SwiftUI

struct FoodSection: View {
    @Environment(\.colorScheme) var colorScheme
    let mealType: String
    let foodItems: [FoodItem]
    @Binding var expandedSections: Set<String> // ✅ Tracks expanded meal sections

    var filteredItems: [FoodItem] {
        foodItems.filter { $0.mealType == mealType } // ✅ Precompute filtered list
    }

    var isExpanded: Bool {
        expandedSections.contains(mealType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // ✅ Custom Toggle Header (Replaces `DisclosureGroup`)
            HStack {
                Image(systemName: isExpanded ? "minus.circle.fill" : "plus.circle.fill") // ✅ Custom icons
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                Text(mealType)
                    .font(.title2)
                    .bold()

                Spacer()
            }
            .padding()
            .background(Color.clear) // ✅ No more grey background
            .onTapGesture {
                withAnimation {
                    if isExpanded {
                        expandedSections.remove(mealType)
                    } else {
                        expandedSections.insert(mealType)
                    }
                }
            }

            // ✅ Show/Hide Food Items Manually
            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    if filteredItems.isEmpty {
                        Text("No entries yet")
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.vertical, 5)
                    } else {
                        ForEach(filteredItems) { food in
                            FoodRow(food: food) // ✅ Displays individual food items
                        }
                    }
                }
                .background(Color.clear) // ✅ Ensure expanded section has no background
            }
        }
        .background(Color.clear) // ✅ Remove all grey background
        .padding(.horizontal)
    }
}

//
//  FoodSection.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//

import SwiftUI

struct FoodSection: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    let mealType: String
    @Binding var expandedSections: Set<String> // ✅ Tracks expanded meal sections

    var filteredItems: [FoodItem] {
        viewModel.foodItems.filter { food in
            food.mealType == mealType && isFoodFromToday(food.date)
        }
    }

    var isExpanded: Bool {
        expandedSections.contains(mealType)
    }
    
    private func isFoodFromToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
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
            .background(Color.clear) // ✅ No grey background
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
                .frame(maxWidth: .infinity) // ✅ Ensures full width
                .background(Color.clear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: isExpanded ? .none : 50) // ✅ Ensures section fully expands
        .background(Color.clear) // ✅ No background issues
        .padding(.horizontal)
    }
}

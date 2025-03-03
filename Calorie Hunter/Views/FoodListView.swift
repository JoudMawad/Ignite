//
//  FoodListView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//
import SwiftUI

struct FoodListView: View {
    @ObservedObject var viewModel: FoodViewModel
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    @State private var expandedSections: Set<String> = [] // ✅ Tracks expanded sections

    var body: some View {
        VStack(alignment: .leading, spacing: 6) { // ✅ Removed ScrollView to avoid nested scrolling
            ForEach(mealTypes, id: \.self) { meal in
                FoodSection(viewModel: viewModel, mealType: meal, expandedSections: $expandedSections)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal, 8)
                    .animation(.easeInOut(duration: 0.3), value: expandedSections)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

//
//  FoodListView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 02.03.25.
//
import SwiftUI

struct FoodListView: View {
    @ObservedObject var viewModel: FoodViewModel
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    @State private var expandedSections: Set<String> = [] // ✅ Tracks expanded sections

    var body: some View {
        NavigationView {
            List {
                ForEach(mealTypes, id: \.self) { meal in
                    FoodSection(mealType: meal, foodItems: viewModel.foodItems, expandedSections: $expandedSections)
                }
            }
            .listStyle(.plain) // ✅ Removes background color from List
        }
    }
}


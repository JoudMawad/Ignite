//
//  ContentView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 01.03.25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var viewModel = FoodViewModel() // Store food data
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView { // Enable full-screen scrolling
                VStack {
                    FoodChartView(
                        totalProtein: viewModel.totalProtein,
                        totalCarbs: viewModel.totalCarbs,
                        totalFat: viewModel.totalFat
                    )
                    .onAppear {
                        viewModel.loadFromUserDefaults()
                    }
                    .frame(height: 300)
                    .padding()

                    Text("Protein: \(viewModel.totalProtein, specifier: "%.1f") g, Carbs: \(viewModel.totalCarbs, specifier: "%.1f") g, Fat: \(viewModel.totalFat, specifier: "%.1f") g")
                        .font(.subheadline)
                        .padding()

                    Text("Total Calories: \(viewModel.totalCalories) kcal")
                        .font(.largeTitle)
                        .padding()

                    // ✅ Use ExpandingButton with correct navigation
                    ExpandingButton(title: "Add Food") {
                        openAddFoodView()
                    }

                    // ✅ Food List View
                    FoodListView(viewModel: viewModel)

                    // ✅ Reset Button
                    ExpandingButton(title: "Reset") {
                        viewModel.resetFood()
                    }
                    .background(Color.primary) // ✅ Custom color for Reset button
                }
            }
        }
    }
    
    // ✅ Function to Open `AddFoodView` Without Deprecated API
    private func openAddFoodView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let addFoodView = AddFoodView(viewModel: viewModel)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}
#Preview {
    ContentView() 
    }

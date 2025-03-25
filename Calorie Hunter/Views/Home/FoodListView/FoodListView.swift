import SwiftUI

struct FoodListView: View {
    // View model that manages food data.
    @ObservedObject var viewModel: FoodViewModel
    
    // List of meal types to display sections for.
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    // A set to track which sections are expanded.
    @State private var expandedSections: Set<String> = []
    
    // Closure to add a new food item, parameterized by meal type.
    var addFoodAction: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Iterate over each meal type to create a separate section.
            ForEach(mealTypes, id: \.self) { meal in
                FoodSection(
                    viewModel: viewModel,
                    mealType: meal,
                    expandedSections: $expandedSections,
                    addFoodAction: addFoodAction // Pass the closure to handle adding food.
                )
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .cornerRadius(10)
                .padding(.horizontal, 8)
                // Animate changes in the expandedSections state.
                .animation(.easeInOut(duration: 0.3), value: expandedSections)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

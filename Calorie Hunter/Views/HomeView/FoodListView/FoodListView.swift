import SwiftUI

struct FoodListView: View {
    @ObservedObject var viewModel: FoodViewModel
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    @State private var expandedSections: Set<String> = [] // Tracks expanded sections
    
    // New closure property that takes a meal type as an argument.
    var addFoodAction: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(mealTypes, id: \.self) { meal in
                FoodSection(
                    viewModel: viewModel,
                    mealType: meal,
                    expandedSections: $expandedSections,
                    addFoodAction: addFoodAction // Passing the closure
                )
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

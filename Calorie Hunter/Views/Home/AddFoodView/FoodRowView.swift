import SwiftUI

struct FoodRowView: View {
    // The food item to display.
    var food: FoodItem
    // View model for managing food-related data and actions.
    @ObservedObject var viewModel: FoodViewModel
    // Adapt the view's colors based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    // The meal type (e.g., Breakfast, Lunch) passed from the parent.
    let mealType: String

    // State to track whether the expanded section is shown.
    @State private var isExpanded: Bool = false
    // State to store the user's input for grams consumed.
    @State private var gramsInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row with the food name and an expand/collapse button.
            HStack {
                // Display the food's name.
                Text(food.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))

                Spacer()
                // Button toggles the expanded section.
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded.toggle()
                    }
                } label: {
                    // Icon changes based on the expansion state.
                    Image(systemName: isExpanded ? "chevron.up" : "plus.circle")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            // Background adapts based on the color scheme.
            .background(colorScheme == .dark ? Color.black : Color.white)
            
            // Expanded section for entering grams consumed.
            VStack(spacing: 8) {
                // Text field for entering grams.
                TextField("Grams Consumed", text: $gramsInput)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                    .padding(5)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                
                // Button to add the food entry.
                ExpandingButton(title: "Add") {
                    // Convert the input to Double, handling both commas and dots.
                    guard let gramsValue = Double(gramsInput.replacingOccurrences(of: ",", with: ".")) else {
                        return
                    }
                    // Add the predefined food using the passed mealType.
                    viewModel.addPredefinedFood(food: food, gramsConsumed: gramsValue, mealType: mealType)
                    
                    // Collapse the expanded section and reset the input.
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded = false
                    }
                    gramsInput = ""
                }
            }
            .padding()
            // Use a consistent background color.
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(8)
            // Expand or collapse the section by adjusting the height.
            .frame(maxHeight: isExpanded ? nil : 0)
            // Fade the section in/out based on expansion.
            .opacity(isExpanded ? 1 : 0)
            .clipped()
            
            // A divider to separate rows.
            Divider().background(colorScheme == .dark ? Color.black : Color.white)
        }
        // Apply animation when the expanded state changes.
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1), value: isExpanded)
        .padding(.horizontal)
    }
}

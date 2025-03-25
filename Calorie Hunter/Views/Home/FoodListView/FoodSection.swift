import SwiftUI

struct FoodSection: View {
    // ViewModel to access food data and actions.
    @ObservedObject var viewModel: FoodViewModel
    // Adapt UI styling based on the system color scheme.
    @Environment(\.colorScheme) var colorScheme
    // The meal type for this section (e.g., Breakfast, Lunch).
    let mealType: String
    // Binding to track which sections are expanded.
    @Binding var expandedSections: Set<String>
    
    // Closure triggered when the plus icon is tapped to add a new food.
    var addFoodAction: (String) -> Void

    // State to track if the section is in edit mode.
    @State private var isEditing = false

    /// Filters food items to include only those matching the meal type and added today.
    var filteredItems: [FoodItem] {
        viewModel.foodItems.filter { food in
            food.mealType == mealType && isFoodFromToday(food.date)
        }
    }

    /// Check if the section for this meal type is currently expanded.
    var isExpanded: Bool {
        expandedSections.contains(mealType)
    }
    
    /// Helper to check if a given date is today.
    private func isFoodFromToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Calculate the total calories for the given meal type.
    var totalCalories: Int {
        viewModel.totalCaloriesForMealType(mealType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header row with meal name, calories, edit button, and add icon.
            HStack {
                // Icon indicating whether the section is expanded.
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                // Meal type title.
                Text(mealType)
                    .font(.system(size: 25, weight: .bold, design: .rounded))

                Spacer()

                // Display total calories for the meal type.
                Text("\(totalCalories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Conditionally show an "Edit" button if the section is expanded and contains items.
                if isExpanded && !filteredItems.isEmpty {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Button to add a new food entry; triggers the provided closure.
                Button(action: {
                    addFoodAction(mealType)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 5)
            }
            .padding(.vertical, 10)
            .background(Color.clear)
            // Tapping the header toggles the expanded state.
            .onTapGesture {
                withAnimation {
                    if isExpanded {
                        expandedSections.remove(mealType)
                        isEditing = false // Reset edit mode when collapsing.
                    } else {
                        expandedSections.insert(mealType)
                    }
                }
            }

            // Conditionally show the list of food items when the section is expanded.
            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    if filteredItems.isEmpty {
                        // Show a placeholder message if there are no entries.
                        Text("No entries yet")
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.vertical, 5)
                    } else {
                        // Display each food item in a row.
                        ForEach(filteredItems) { food in
                            HStack {
                                FoodRow(food: food)
                                Spacer()
                                // Show a red minus icon for deletion when in edit mode.
                                if isEditing {
                                    Button(action: {
                                        viewModel.removeFood(by: food.id)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
        }
        // Set a fixed height when collapsed; expand to fit content when expanded.
        .frame(maxWidth: .infinity, maxHeight: isExpanded ? .none : 50)
        .background(Color.clear)
        .padding(.horizontal)
    }
    
    /// Opens the AddFoodView for the specified meal type.
    /// (Note: This helper is currently unused because addFoodAction is passed from the parent.)
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            // Initialize AddFoodView with the meal type preset.
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

import SwiftUI

struct FoodSection: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    let mealType: String
    @Binding var expandedSections: Set<String>

    @State private var isEditing = false // Track edit mode

    var filteredItems: [FoodItem] {
        viewModel.foodItems.filter { food in
            food.mealType == mealType && isFoodFromToday(food.date)
        }
    }

    var isExpanded: Bool {
        expandedSections.contains(mealType)
    }
    
    private func isFoodFromToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    var totalCalories: Int {
        viewModel.totalCaloriesForMeal(mealType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header with meal name, total calories, and "Edit" button
            HStack {
                Image(systemName: isExpanded ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                Text(mealType)
                    .font(.title2)
                    .bold()

                Spacer()

                // Display total calories
                Text("\(totalCalories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isExpanded && !filteredItems.isEmpty { // Edit button appears only when expanded & has items
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.clear)
            .onTapGesture {
                withAnimation {
                    if isExpanded {
                        expandedSections.remove(mealType)
                        isEditing = false // Reset edit mode when collapsing
                    } else {
                        expandedSections.insert(mealType)
                    }
                }
            }

            // Show food items only when expanded
            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    if filteredItems.isEmpty {
                        Text("No entries yet")
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.vertical, 5)
                    } else {
                        ForEach(filteredItems) { food in
                            HStack {
                                FoodRow(food: food)
                                Spacer()
                                
                                if isEditing { // Show red minus only when editing
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
        .frame(maxWidth: .infinity, maxHeight: isExpanded ? .none : 50)
        .background(Color.clear)
        .padding(.horizontal)
    }
}

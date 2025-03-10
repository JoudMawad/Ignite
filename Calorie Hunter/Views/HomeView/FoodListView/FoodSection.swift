import SwiftUI

struct FoodSection: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    let mealType: String
    @Binding var expandedSections: Set<String>
    
    // New closure property that will be triggered when the plus icon is tapped.
    var addFoodAction: (String) -> Void

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
        Calendar.current.isDateInToday(date)
    }
    
    var totalCalories: Int {
        viewModel.totalCaloriesForMealType(mealType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header with meal name, total calories, plus icon, and "Edit" button
            HStack {
                // Plus Icon Button to open add food view with preselected meal type
                

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                Text(mealType)
                    .font(.system(size: 25, weight: .bold, design: .rounded))

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
                
                Button(action: {
                    addFoodAction(mealType)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 5)
            }
            .padding(.vertical, 10)
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
    
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            // Initialize AddFoodView with the mealType already set.
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }

}


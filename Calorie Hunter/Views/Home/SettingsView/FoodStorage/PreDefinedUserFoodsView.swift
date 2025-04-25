import SwiftUI

struct PreDefinedFoodRow: View {
    @Environment(\.colorScheme) var colorScheme
    var food: FoodItem
    @ObservedObject var viewModel: UserPreDefinedFoodsViewModel
    @State private var isExpanded: Bool = false

    // Formatted nutritional strings
    private var proteinText: String { String(format: "%.1f", food.protein) }
    private var carbsText: String   { String(format: "%.1f", food.carbs) }
    private var fatText: String     { String(format: "%.1f", food.fat) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(food.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color.black : Color.white)

            // Expanded detail section
            VStack(alignment: .leading, spacing: 8) {
                Text("Calories: \(food.calories)")
                Text("Protein: \(proteinText) g")
                Text("Carbs: \(carbsText) g")
                Text("Fat: \(fatText) g")
                Text("Grams: \(food.grams) g")
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(8)
            .frame(maxHeight: isExpanded ? .infinity : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()
            
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

struct UserPreDefinedFoodsView: View {
    // Adapt UI styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    // View model managing the list of predefined (user-added) food items.
    @StateObject private var viewModel = UserPreDefinedFoodsViewModel()
    // State to store the search text entered by the user.
    @State private var searchText = ""
    @State private var isEditing: Bool = false
    @State private var foodToEdit: FoodItem? = nil

    /// Filters the food items based on the search text.
    /// If searchText is empty, all foods are returned; otherwise, only those whose name contains the search text.
    var filteredFoods: [FoodItem] {
        if searchText.isEmpty {
            return viewModel.foods
        } else {
            return viewModel.foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Header title for the Storage view.
                Text("Storage")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.bottom, 5)
                    .padding(.trailing, 200)
                    .padding(.top, -50)
                
                // Search bar to filter food items.
                TextField("Search food...", text: $searchText)
                    .padding(10)
                    .foregroundColor(.primary) // Uses primary color for text.
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .background(
                        // Background with rounded corners, fill color adjusted for light/dark mode, and a subtle shadow.
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(color: Color.gray.opacity(0.3), radius: 8)
                            .padding(.horizontal, 30)
                    )
                    .padding(.top, 25)
                    .padding(.bottom, 9)

                // List view to display the filtered food items.
                ScrollView() {
                    ForEach(Array(filteredFoods.enumerated()), id: \.element.id) { index, food in
                        HStack {
                            if isEditing {
                                Button(action: {
                                    viewModel.removeFood(by: food.id)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                Button(action: {
                                    // Trigger editing for this food item
                                    foodToEdit = food
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 22))
                                }
                                .padding(.horizontal, 4)
                            }
                            PreDefinedFoodRow(food: food, viewModel: viewModel)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal, 5)
                // Hides the default scroll background.
                .scrollContentBackground(.hidden)
                // Sets a consistent background for the list.
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            // Ensure the entire view has the proper background.
            .background(colorScheme == .dark ? Color.black : Color.white)
            .toolbar {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
        .sheet(item: $foodToEdit) { item in
            // Replace with your actual edit view; passing the viewModel and the selected food
            ManualEntryView(viewModel: viewModel, scannedBarcode: nil, existingFood: item, onSuccessfulDismiss: {
                foodToEdit = nil
            })
        }
    }
}

// MARK: - Preview with Sample Data
struct UserPreDefinedFoodsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview view model with sample data.
        let previewViewModel = UserPreDefinedFoodsViewModel()

        previewViewModel.foods = [
            FoodItem(
                id: UUID(),
                name: "Apple",
                calories: 52,
                protein: 0.3,
                carbs: 14.0,
                fat: 0.2,
                grams: 100,
                mealType: "Snack",
                date: Date(),
                isUserAdded: true
            ),
            FoodItem(
                id: UUID(),
                name: "Chicken Breast",
                calories: 165,
                protein: 31.0,
                carbs: 0.0,
                fat: 3.6,
                grams: 100,
                mealType: "Lunch",
                date: Date(),
                isUserAdded: true
            )
        ]

        // Provide the preview view with the view model as an environment object.
        return UserPreDefinedFoodsView()
            .environmentObject(previewViewModel)
    }
}

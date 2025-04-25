import SwiftUI

struct PreDefinedFoodRow: View {
    @Environment(\.colorScheme) var colorScheme
    var food: FoodItem
    @ObservedObject var viewModel: UserPreDefinedFoodsViewModel
    var onDelete: (() -> Void)? = nil
    @State private var isExpanded: Bool = false

    // Editable fields
    @State private var editName: String = ""
    @State private var editCalories: String = ""
    @State private var editProtein: String = ""
    @State private var editCarbs: String = ""
    @State private var editFat: String = ""
    @State private var editGrams: String = ""

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
                        if isExpanded {
                            // Close expansion
                            isExpanded = false
                        } else {
                            // Initialize editable fields when opening
                            editName = food.name
                            editCalories = String(food.calories)
                            editProtein = String(food.protein)
                            editCarbs = String(food.carbs)
                            editFat = String(food.fat)
                            editGrams = String(food.grams)
                            isExpanded = true
                        }
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.primary)
                        .font(.system(size: 20))
                }
                .padding(.leading, 4)
                if isExpanded {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color.black : Color.white)

            // Expanded detail section
            if isExpanded {
                // Editable fields with improved UI
                VStack(alignment: .leading, spacing: 16) {
                    // Name field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Name", text: $editName)
                            .font(.body)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    // Nutrition fields in two columns
                    HStack(spacing: 12) {
                        // Calories
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0", text: $editCalories)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        // Protein
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protein (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editProtein)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    HStack(spacing: 12) {
                        // Carbs
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Carbs (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editCarbs)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        // Fat
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fat (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editFat)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    // Grams field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grams (g)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("0.0", text: $editGrams)
                            .keyboardType(.decimalPad)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    // Action buttons
                    HStack(spacing: 16) {
                        Button("Save") {
                            // existing save logic
                            guard
                                let cals = Int(editCalories),
                                let prot = Double(editProtein),
                                let carbsVal = Double(editCarbs),
                                let fatVal = Double(editFat),
                                let gramsVal = Double(editGrams)
                            else { return }
                            let updatedItem = FoodItem(
                                id: food.id,
                                name: editName,
                                calories: cals,
                                protein: prot,
                                carbs: carbsVal,
                                fat: fatVal,
                                grams: gramsVal,
                                mealType: food.mealType,
                                date: food.date,
                                isUserAdded: food.isUserAdded,
                                barcode: food.barcode
                            )
                            viewModel.updateFood(updatedItem)
                            isExpanded = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primary)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                        

                        Button("Delete") {
                            onDelete?()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()
                .background(colorScheme == .dark ? .black : .white)
                .cornerRadius(12)
            }
            
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
    @State private var foodToEdit: FoodItem? = nil

    // MARK: - Subviews for body
    private var headerView: some View {
        VStack {
            Text("Storage")
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 5)
                .padding(.trailing, 200)
                .padding(.top, -50)
            TextField("Search food...", text: $searchText)
                .padding(10)
                .foregroundColor(.primary)
                .cornerRadius(10)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? .black : .white)
                        .shadow(color: .gray.opacity(0.3), radius: 8)
                        .padding(.horizontal, 30)
                )
                .padding(.vertical, 9)
        }
    }

    private var foodsListView: some View {
        ScrollView {
            ForEach(Array(filteredFoods.enumerated()), id: \.element.id) { _, food in
                PreDefinedFoodRow(
                    food: food,
                    viewModel: viewModel,
                    onDelete: { viewModel.removeFood(by: food.id) }
                )
                Divider()
            }
        }
        .padding(.horizontal, 5)
        .scrollContentBackground(.hidden)
        .background(colorScheme == .dark ? .black : .white)
    }

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
            VStack(spacing: 0) {
                headerView
                foodsListView
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
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

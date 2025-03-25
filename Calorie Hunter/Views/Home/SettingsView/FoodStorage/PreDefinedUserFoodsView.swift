import SwiftUI

struct UserPreDefinedFoodsView: View {
    // Adapt UI styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    // View model managing the list of predefined (user-added) food items.
    @StateObject private var viewModel = UserPreDefinedFoodsViewModel()
    // State to store the search text entered by the user.
    @State private var searchText = ""

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
                List {
                    ForEach(filteredFoods) { food in
                        HStack {
                            // Food information section.
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Calories: \(food.calories)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            // Trash button to remove a food item.
                            Button(action: {
                                viewModel.removeFood(by: food.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        // Adjust the background of each row based on the current color scheme.
                        .listRowBackground(colorScheme == .dark ? Color.black : Color.white)
                    }
                    // Allow deletion of items using swipe-to-delete.
                    .onDelete(perform: viewModel.deleteFood)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 5)
                // Hides the default scroll background.
                .scrollContentBackground(.hidden)
                // Sets a consistent background for the list.
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            // Ensure the entire view has the proper background.
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

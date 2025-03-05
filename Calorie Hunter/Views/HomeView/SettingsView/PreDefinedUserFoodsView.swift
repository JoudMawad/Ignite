import SwiftUI

struct UserPreDefinedFoodsView: View {
    @StateObject private var viewModel = UserPreDefinedFoodsViewModel()
    @State private var searchText = "" // Search text state

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
                // Search Bar
                TextField("Search food...", text: $searchText)
                    .padding(10)
                    .background(Color.black.opacity(0.8)) // Dark background
                    .foregroundColor(.white) // White text
                    .cornerRadius(10)
                    .padding(.horizontal)

                List {
                    ForEach(filteredFoods) { food in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.white) // White text
                                Text("Calories: \(food.calories)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray) // Light gray subtext
                            }
                            Spacer()
                            Button(action: {
                                viewModel.removeFood(by: food.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(Color.black) // Ensure row stays black
                    }
                    .onDelete(perform: viewModel.deleteFood)
                }
                .scrollContentBackground(.hidden) // Hide default gray background
                .background(Color.black) //  Black background
            }
            .navigationTitle("Food Storage")
            
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Ensures full black background
        }
    }
}

// MARK: - Preview with Sample Data
struct UserPreDefinedFoodsView_Previews: PreviewProvider {
    static var previews: some View {
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

        return UserPreDefinedFoodsView()
            .environmentObject(previewViewModel)
    }
}

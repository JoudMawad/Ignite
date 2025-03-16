import SwiftUI

struct UserPreDefinedFoodsView: View {
    @Environment(\.colorScheme) var colorScheme
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
                
                Text("Storage")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.bottom, 5)
                    .padding(.trailing, 200)
                    .padding(.top, -50)
                
                    
                // Search Bar
                TextField("Search food...", text: $searchText)
                    .padding(10)
                    .foregroundColor(.primary) // White text
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(color: Color.gray.opacity(0.3), radius: 8)
                            .padding(.horizontal, 30)
                      )
                    .padding(.top, 25)
                    .padding(.bottom, 9)

                List {
                    ForEach(filteredFoods) { food in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Calories: \(food.calories)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.removeFood(by: food.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? Color.black : Color.white)
                    }
                    .onDelete(perform: viewModel.deleteFood)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 5)
                .scrollContentBackground(.hidden)
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            
            .background(colorScheme == .dark ? Color.black : Color.white) // Ensures full black background
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

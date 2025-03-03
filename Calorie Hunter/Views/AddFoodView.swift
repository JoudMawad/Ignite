import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var grams: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var selectedPredefinedFood: FoodItem?
    @State private var searchText: String = ""

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    private var isManualInputValid: Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
               !grams.trimmingCharacters(in: .whitespaces).isEmpty &&
               !calories.trimmingCharacters(in: .whitespaces).isEmpty &&
               !protein.trimmingCharacters(in: .whitespaces).isEmpty &&
               !carbs.trimmingCharacters(in: .whitespaces).isEmpty &&
               !fat.trimmingCharacters(in: .whitespaces).isEmpty &&
               Double(grams) != nil &&
               Double(calories) != nil &&
               Double(protein) != nil &&
               Double(carbs) != nil &&
               Double(fat) != nil
    }

    private var filteredFoods: [FoodItem] {
        if searchText.isEmpty {
            return PredefinedFoods.foods
        } else {
            return PredefinedFoods.foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                //Show search only when no food is selected
                if selectedPredefinedFood == nil {
                    Section(header: Text("Search Predefined Foods")) {
                        TextField("Search food...", text: $searchText)
                        
                        if !filteredFoods.isEmpty {
                            ScrollView {
                                VStack(spacing: 2) {
                                    ForEach(filteredFoods, id: \.id) { food in
                                        Button(action: {
                                            selectedPredefinedFood = food
                                            searchText = "" //Hide search after selection
                                        }) {
                                            HStack {
                                                Text(food.name)
                                                    .foregroundColor(.primary)
                                                    .padding(.vertical, 6)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                        }
                                        Divider()
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                }

                //Show selected food only after choosing
                if let selectedFood = selectedPredefinedFood {
                    Section(header: Text("Selected Food")) {
                        HStack {
                            Text(selectedFood.name)
                                .font(.headline)
                            Spacer()
                            Button(action: { selectedPredefinedFood = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }

                        TextField("Grams Consumed", text: $grams)
                            .keyboardType(.decimalPad)

                        Picker("Meal Type", selection: $mealType) {
                            ForEach(mealTypes, id: \.self) { meal in
                                Text(meal).tag(meal)
                            }
                        }
                    }
                }

                //Manual Entry for Custom Food
                Section(header: Text("Manual Entry")) {
                    TextField("Food Name", text: $name)
                    TextField("Grams Consumed", text: $grams)
                        .keyboardType(.decimalPad)
                    TextField("Calories", text: $calories).keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $carbs).keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $fat).keyboardType(.decimalPad)

                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { meal in
                            Text(meal).tag(meal)
                        }
                    }
                }
            }
            .navigationTitle("Add Food")
            
            ExpandingButton(title: "Add Food") {
                if let selectedPredefinedFood = selectedPredefinedFood, let gramsDouble = Double(grams) {
                    viewModel.addPredefinedFood(food: selectedPredefinedFood, gramsConsumed: gramsDouble, mealType: mealType)
                } else if isManualInputValid {
                    let gramsDouble = Double(grams) ?? 100
                    let adjustedCalories = Int((Double(calories) ?? 0) * gramsDouble / 100)
                    let adjustedProtein = (Double(protein) ?? 0) * gramsDouble / 100
                    let adjustedCarbs = (Double(carbs) ?? 0) * gramsDouble / 100
                    let adjustedFat = (Double(fat) ?? 0) * gramsDouble / 100

                    viewModel.addFood(
                        name: name,
                        calories: adjustedCalories,
                        protein: adjustedProtein,
                        carbs: adjustedCarbs,
                        fat: adjustedFat,
                        grams: gramsDouble,
                        mealType: mealType
                    )
                }
                dismiss()
            }
            .disabled((selectedPredefinedFood == nil && !isManualInputValid) || (selectedPredefinedFood != nil && grams.isEmpty))
        }
    }
}

#Preview {
    AddFoodView(viewModel: FoodViewModel())
}

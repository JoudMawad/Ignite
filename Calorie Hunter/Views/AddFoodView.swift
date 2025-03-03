import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var grams: String = "" // ✅ Ensure grams is included
    @State private var mealType: String = "Breakfast"
    @State private var selectedPredefinedFood: FoodItem?

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // ✅ Check if manual input fields are filled
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

    var body: some View {
        NavigationStack {
            Form {
                // ✅ Predefined Food Selection
                Section(header: Text("Predefined Foods")) {
                    Picker("Select Food", selection: $selectedPredefinedFood) {
                        ForEach(PredefinedFoods.foods, id: \.id) { food in
                            Text(food.name).tag(food as FoodItem?)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    if selectedPredefinedFood != nil {
                        TextField("Grams Consumed", text: $grams)
                            .keyboardType(.decimalPad)

                        Picker("Meal Type", selection: $mealType) {
                            ForEach(mealTypes, id: \.self) { meal in
                                Text(meal).tag(meal)
                            }
                        }
                    }
                }

                // ✅ Manual Entry for Custom Food
                Section(header: Text("Manual Entry")) {
                    TextField("Food Name", text: $name)
                    TextField("Grams Consumed", text: $grams) // ✅ Add back grams input
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
                    let gramsDouble = Double(grams) ?? 100 // Default to 100g if missing
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

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

    @State private var errorMessages: [String] = [] // Stores multiple errors
    @State private var successMessage: String? // Stores success message
    
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

    var body: some View {
        NavigationStack {
            Form {
                // Search Predefined Foods (Only shows when user types)
                if selectedPredefinedFood == nil {
                    Section(header: Text("Search Predefined Foods")) {
                        TextField("Search food...", text: $searchText)

                        let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
                        let filteredFoods = searchText.isEmpty ? [] : allFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

                        if !filteredFoods.isEmpty {
                            ScrollView {
                                VStack(spacing: 2) {
                                    ForEach(filteredFoods, id: \.id) { food in
                                        Button(action: {
                                            selectedPredefinedFood = food
                                            searchText = "" // Hide search after selection
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

                // Show selected food
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

                // Manual Entry for Custom Food
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

                    // Display multiple error messages
                    if !errorMessages.isEmpty {
                        ForEach(errorMessages, id: \.self) { message in
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    // Button to Save as Predefined Food (Does not exit)
                    ExpandingButton(title: "Add to Food Storage") {
                        errorMessages = [] // Clear previous errors

                        if !isManualInputValid {
                            errorMessages.append("All fields must be filled.")
                        }

                        if let gramsValue = Double(grams), gramsValue != 100 {
                            errorMessages.append("Grams must be exactly 100.")
                        }

                        // Check for duplicate food names
                        let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
                        if allFoods.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                            errorMessages.append("A food with this name already exists.")
                        }

                        // If no errors, save food
                        if errorMessages.isEmpty {
                            let newFood = FoodItem(
                                name: name,
                                calories: Int(calories) ?? 0,
                                protein: Double(protein) ?? 0,
                                carbs: Double(carbs) ?? 0,
                                fat: Double(fat) ?? 0,
                                grams: 100,
                                mealType: mealType
                            )
                            successMessage = "Food successfully added to storage!" // ✅ Show success message

                            // Auto-hide success message after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                successMessage = nil
                            }
                            viewModel.addUserPredefinedFood(food: newFood)
                        }
                    }
                    
                    ExpandingButton(title: "Add Food") {
                        if let gramsValue = Double(grams), gramsValue == 100 {
                            if let selectedPredefinedFood = selectedPredefinedFood {
                                viewModel.addPredefinedFood(food: selectedPredefinedFood, gramsConsumed: gramsValue, mealType: mealType)
                            } else if isManualInputValid {
                                let adjustedCalories = Int((Double(calories) ?? 0) * gramsValue / 100)
                                let adjustedProtein = (Double(protein) ?? 0) * gramsValue / 100
                                let adjustedCarbs = (Double(carbs) ?? 0) * gramsValue / 100
                                let adjustedFat = (Double(fat) ?? 0) * gramsValue / 100

                                viewModel.addFood(
                                    name: name,
                                    calories: adjustedCalories,
                                    protein: adjustedProtein,
                                    carbs: adjustedCarbs,
                                    fat: adjustedFat,
                                    grams: gramsValue,
                                    mealType: mealType
                                )
                            }
                            dismiss() // ✅ Now exits the view after adding food
                        }
                    }
                    .disabled(Double(grams) != 100)
                }
            }
            .navigationTitle("Add Food")
        }
    }
}

#Preview {
    AddFoodView(viewModel: FoodViewModel())
}

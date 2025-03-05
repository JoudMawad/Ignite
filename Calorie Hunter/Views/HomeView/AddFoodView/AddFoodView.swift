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

    @State private var errorMessages: [String] = []
    @State private var successMessage: String?

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // Function to sanitize numeric input by replacing "," with "."
    func sanitizeDoubleInput(_ input: String) -> Double? {
        return Double(input.replacingOccurrences(of: ",", with: "."))
    }

    private var isManualInputValid: Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
               !grams.trimmingCharacters(in: .whitespaces).isEmpty &&
               !calories.trimmingCharacters(in: .whitespaces).isEmpty &&
               !protein.trimmingCharacters(in: .whitespaces).isEmpty &&
               !carbs.trimmingCharacters(in: .whitespaces).isEmpty &&
               !fat.trimmingCharacters(in: .whitespaces).isEmpty &&
               sanitizeDoubleInput(grams) != nil &&
               sanitizeDoubleInput(calories) != nil &&
               sanitizeDoubleInput(protein) != nil &&
               sanitizeDoubleInput(carbs) != nil &&
               sanitizeDoubleInput(fat) != nil
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Search Predefined Foods
                if selectedPredefinedFood == nil {
                    TextField("Search food...", text: $searchText)
                        .padding(10)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)

                    let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
                    let filteredFoods = searchText.isEmpty ? [] : allFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

                    if !filteredFoods.isEmpty {
                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(filteredFoods, id: \.id) { food in
                                    Button(action: {
                                        selectedPredefinedFood = food
                                        searchText = ""
                                    }) {
                                        HStack {
                                            Text(food.name)
                                                .foregroundColor(.white.opacity(0.8))
                                                .padding(.vertical, 6)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                    Divider().background(Color.black)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }

                Form {
                    if let selectedFood = selectedPredefinedFood {
                        Section(header: Text("Selected Food").foregroundColor(.white)) {
                            HStack {
                                Text(selectedFood.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
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
                                    Text(meal)
                                        .foregroundColor(.white)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.gray)
                        }
                        .listRowBackground(Color.black)
                    }

                    // Manual Entry Section
                    Section(header: Text("Manual Entry").foregroundColor(.white)) {
                        TextField("Food Name", text: $name)

                        TextField("Grams Consumed", text: $grams)
                            .keyboardType(.decimalPad)

                        TextField("Calories", text: $calories)
                            .keyboardType(.decimalPad)

                        TextField("Protein (g)", text: $protein)
                            .keyboardType(.decimalPad)

                        TextField("Carbs (g)", text: $carbs)
                            .keyboardType(.decimalPad)

                        TextField("Fat (g)", text: $fat)
                            .keyboardType(.decimalPad)

                        Picker("Meal Type", selection: $mealType) {
                            ForEach(mealTypes, id: \.self) { meal in
                                Text(meal).tag(meal)
                            }
                        }
                        .foregroundColor(.gray.opacity(0.5))
                        .pickerStyle(MenuPickerStyle())
                        .tint(.gray)

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

                        ExpandingButton(title: "Add to Food Storage") {
                            errorMessages = []

                            if !isManualInputValid {
                                errorMessages.append("All fields must be filled.")
                                
                                if let gramsValue = sanitizeDoubleInput(grams) {
                                    if gramsValue != 100 {
                                        errorMessages.append("Grams must be exactly 100.")
                                    }
                                } else if grams.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    errorMessages.append("Grams must be exactly 100.")
                                }
                            }

                            let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
                            if allFoods.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                                errorMessages.append("A food with this name already exists.")
                            }

                            if errorMessages.isEmpty {
                                let newFood = FoodItem(
                                    name: name,
                                    calories: Int(calories) ?? 0,
                                    protein: sanitizeDoubleInput(protein) ?? 0,
                                    carbs: sanitizeDoubleInput(carbs) ?? 0,
                                    fat: sanitizeDoubleInput(fat) ?? 0,
                                    grams: 100,
                                    mealType: mealType
                                )
                                successMessage = "Food successfully added to storage!"

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    successMessage = nil
                                }
                                viewModel.addUserPredefinedFood(food: newFood)
                            }
                        }

                        ExpandingButton(title: "Add") {
                            errorMessages = []

                            if !isManualInputValid {
                                errorMessages.append("All fields must be filled.")
                            }
                            
                            if let gramsValue = sanitizeDoubleInput(grams) {
                                if let selectedPredefinedFood = selectedPredefinedFood {
                                    viewModel.addPredefinedFood(food: selectedPredefinedFood, gramsConsumed: gramsValue, mealType: mealType)
                                } else if isManualInputValid {
                                    let adjustedCalories = Int((sanitizeDoubleInput(calories) ?? 0) * gramsValue / 100)
                                    let adjustedProtein = (sanitizeDoubleInput(protein) ?? 0) * gramsValue / 100
                                    let adjustedCarbs = (sanitizeDoubleInput(carbs) ?? 0) * gramsValue / 100
                                    let adjustedFat = (sanitizeDoubleInput(fat) ?? 0) * gramsValue / 100

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
                                dismiss()
                            }
                        }
                    }
                    .listRowBackground(Color.black)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("Add Food")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    AddFoodView(viewModel: FoodViewModel())
}

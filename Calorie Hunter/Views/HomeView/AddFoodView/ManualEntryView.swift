//
//  ManualEntryView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import SwiftUI

struct ManualEntryView: View {
    // MARK: - Observed and Environment Properties
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    // MARK: - State Properties
    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var grams: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var errorMessages: [String] = []
    @State private var successMessage: String?

    // List of meal types
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // MARK: - Helper Functions
    /// Converts input string to Double after replacing commas with dots.
    func sanitizeDoubleInput(_ input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: "."))
    }
    
    // MARK: - Validation
    /// Validates that all fields are non-empty and that numeric fields can be converted.
    private var isManualInputValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedGrams = grams.trimmingCharacters(in: .whitespaces)
        let trimmedCalories = calories.trimmingCharacters(in: .whitespaces)
        let trimmedProtein = protein.trimmingCharacters(in: .whitespaces)
        let trimmedCarbs = carbs.trimmingCharacters(in: .whitespaces)
        let trimmedFat = fat.trimmingCharacters(in: .whitespaces)
        
        let areFieldsNonEmpty = !trimmedName.isEmpty &&
                                !trimmedGrams.isEmpty &&
                                !trimmedCalories.isEmpty &&
                                !trimmedProtein.isEmpty &&
                                !trimmedCarbs.isEmpty &&
                                !trimmedFat.isEmpty
        
        let areNumericValuesValid = sanitizeDoubleInput(trimmedGrams) != nil &&
                                    sanitizeDoubleInput(trimmedCalories) != nil &&
                                    sanitizeDoubleInput(trimmedProtein) != nil &&
                                    sanitizeDoubleInput(trimmedCarbs) != nil &&
                                    sanitizeDoubleInput(trimmedFat) != nil
        
        return areFieldsNonEmpty && areNumericValuesValid
    }
    
    // MARK: - Subviews / Computed Properties

    /// Group of text fields and picker for food inputs.
    private var foodInputFields: some View {
        Group {
            TextField("Food Name", text: $name)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            TextField("Grams Consumed", text: $grams)
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            TextField("Calories", text: $calories)
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            TextField("Protein (g)", text: $protein)
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            TextField("Carbs (g)", text: $carbs)
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            TextField("Fat (g)", text: $fat)
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)
                .padding(5)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(8)
            
            Picker("Meal Type", selection: $mealType) {
                ForEach(mealTypes, id: \.self) { meal in
                    Text(meal).tag(meal)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(.gray)
        }
    }
    
    /// Button to add food to storage with strict validation.
    private var addToFoodStorageButton: some View {
        ExpandingButton(title: "Add to Food Storage") {
            // Clear previous errors
            errorMessages = []
            
            // Validate input fields
            if !isManualInputValid {
                errorMessages.append("All fields must be filled correctly.")
                
                if let gramsValue = sanitizeDoubleInput(grams) {
                    if gramsValue != 100 {
                        errorMessages.append("Grams must be exactly 100.")
                    }
                } else if grams.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    errorMessages.append("Grams must be exactly 100.")
                }
            }
            
            // Check for duplicate food names (case-insensitive)
            let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
            if allFoods.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                errorMessages.append("A food with this name already exists.")
            }
            
            // If no errors, create and add the new food item.
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
                
                // Clear success message after 2 seconds.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    successMessage = nil
                }
                viewModel.addUserPredefinedFood(food: newFood)
            }
        }
    }
    
    /// Button to add food with nutritional values adjusted for grams consumed.
    private var addButton: some View {
        ExpandingButton(title: "Add") {
            // Clear previous errors
            errorMessages = []
            
            if !isManualInputValid {
                errorMessages.append("All fields must be filled correctly.")
            }
            
            // If grams can be converted, adjust the nutritional values accordingly.
            if let gramsValue = sanitizeDoubleInput(grams) {
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
                dismiss()
            }
        }
    }
    
    /// Section displaying error messages.
    private var errorMessagesSection: some View {
        Section {
            ForEach(errorMessages, id: \.self) { message in
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    /// Section displaying a success message.
    private var successMessageSection: some View {
        Section {
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Combine input fields and both buttons in one section.
                    foodInputFields
                    addToFoodStorageButton
                    addButton
                }
                .listRowBackground(colorScheme == .dark ? Color.black : Color.white)
                
                // Show error messages if they exist.
                if !errorMessages.isEmpty {
                    errorMessagesSection
                }
                
                // Show success message if it exists.
                if successMessage != nil {
                    successMessageSection
                }
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationTitle("Manual Entry")
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

#Preview {
    ManualEntryView(viewModel: FoodViewModel())
}

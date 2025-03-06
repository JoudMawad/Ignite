//
//  ManualEntryView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import SwiftUI

struct ManualEntryView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var grams: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var errorMessages: [String] = []
    @State private var successMessage: String?
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // Function to sanitize numeric input by replacing "," with "."
    func sanitizeDoubleInput(_ input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: "."))
    }
    
    private var isManualInputValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
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
        NavigationView {
            Form {
                Section() {
                    TextField("Food Name", text: $name)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    TextField("Grams Consumed", text: $grams)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    TextField("Calories", text: $calories)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(UIColor.black))
                        .cornerRadius(8)
                    
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { meal in
                            Text(meal).tag(meal)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.gray)
                    
                    ExpandingButton(title: "Add to Food Storage") {
                        errorMessages = []
                        
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
                            errorMessages.append("All fields must be filled correctly.")
                        }
                        
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
                .listRowBackground(Color.black)
                
                if !errorMessages.isEmpty {
                    Section {
                        ForEach(errorMessages, id: \.self) { message in
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                
                if let successMessage = successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Manual Entry")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    ManualEntryView(viewModel: FoodViewModel())
}

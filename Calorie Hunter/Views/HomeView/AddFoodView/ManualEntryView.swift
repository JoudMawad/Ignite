//
//  ManualEntryView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//  Revised by [Your Name] on [Today’s Date]

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
    
    // Error and success messages
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
    private var isFormValid: Bool {
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
    
    /// Checks if a food with the same name already exists (case-insensitive).
    private var isDuplicateFood: Bool {
        let allFoods = PredefinedFoods.foods + PredefinedUserFoods.shared.foods
        return allFoods.contains { $0.name.lowercased() == name.lowercased() }
    }

    // MARK: - Body
    var body: some View {
        VStack {
            CardView {
                VStack(alignment: .leading) {
                    // Display error messages (if any) centered with extra bottom padding.
                    if !errorMessages.isEmpty {
                        VStack(spacing: 5) {
                            ForEach(errorMessages, id: \.self) { message in
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .padding(.bottom, 10)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)))
                        .animation(.easeInOut, value: errorMessages)
                    }

                    
                    // Display a success message (if any)
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .transition(.move(edge: .top))
                    }
                    
                    Text("Food Information")
                        .font(.system(size: 25, weight: .bold, design: .default))
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .padding(.bottom, 5)
                    
                    // Input Fields
                    InputField(text: $name, placeholder: "Food Name")
                    InputField(text: $grams, placeholder: "Grams Consumed", keyboardType: .decimalPad)
                    InputField(text: $calories, placeholder: "Calories", keyboardType: .decimalPad)
                    InputField(text: $protein, placeholder: "Protein (g)", keyboardType: .decimalPad)
                    InputField(text: $carbs, placeholder: "Carbs (g)", keyboardType: .decimalPad)
                    InputField(text: $fat, placeholder: "Fat (g)", keyboardType: .decimalPad)
                    
                    // Buttons
                    HStack {
                        ExpandingButton2(title: "Add to Storage") {
                            withAnimation {
                                // Clear previous errors
                                errorMessages = []
                                
                                // Validate fields
                                if !isFormValid {
                                    errorMessages.append("All fields must be filled correctly.")
                                }
                                
                                // Validate grams exactly 100
                                if let gramsValue = sanitizeDoubleInput(grams) {
                                    if gramsValue != 100 {
                                        errorMessages.append("Grams must be exactly 100.")
                                    }
                                } else {
                                    errorMessages.append("Grams must be exactly 100.")
                                }
                                
                                // Check for duplicate food names
                                if isDuplicateFood {
                                    errorMessages.append("A food with this name already exists.")
                                }
                                
                                // If no errors, add the new food item
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
                        }
                        .padding(.top, -10)
                        
                        
                        
                        ExpandingButton2(title: "Add") {
                            withAnimation {
                                // Clear previous errors
                                errorMessages = []
                                
                                if !isFormValid {
                                    errorMessages.append("All fields must be filled correctly.")
                                    return
                                }
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
                        .padding(.top, -10)
                        
                    }
                }.padding(.bottom, -10)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .background(Color(.clear).ignoresSafeArea())
    }
}

//
// MARK: - Custom Card View
struct CardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 55, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 45)
            
    }
}

//
// MARK: - Reusable Input Field View
struct InputField: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text)
            .keyboardType(keyboardType)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
            .placeholder(placeholder, when: text.isEmpty, placeholderColor: .gray)
            .accessibilityLabel(placeholder)
            .font(.system(size: 20, weight: .light, design: .rounded))
            .padding(.vertical, -5)
    }
}

//
// MARK: - Placeholder Modifier
struct PlaceholderStyle: ViewModifier {
    var show: Bool
    var placeholder: String
    var placeholderColor: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if show {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 15)
            }
            content
                .foregroundColor(.primary)
                .padding(10)
        }
    }
}

extension View {
    func placeholder(_ text: String, when shouldShow: Bool, placeholderColor: Color = .gray) -> some View {
        self.modifier(PlaceholderStyle(show: shouldShow, placeholder: text, placeholderColor: placeholderColor))
    }
}

#if canImport(UIKit)
extension View {
    /// Hides the keyboard by resigning the first responder.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                          to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    ManualEntryView(viewModel: FoodViewModel())
}

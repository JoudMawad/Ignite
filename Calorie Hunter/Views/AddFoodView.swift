import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var grams: String = ""
    @State private var mealType: String = "Breakfast" // ✅ Default value
    @State private var date = Date() // ✅ Added for reference
    @FocusState private var isTextFieldFocused: Bool
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Information")) {
                    TextField("Food Name", text: $name)
                    TextField("Grams Consumed", text: $grams)
                        .keyboardType(.decimalPad)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
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
                    .pickerStyle(.navigationLink) // ✅ Matches DatePicker style
                    
                    
                }
            }
            .navigationTitle("Add Food")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            
        }
        ExpandingButton(title: "Add") {
            if let calorieInt = Int(calories),
               let proteinDouble = Double(protein),
               let carbsDouble = Double(carbs),
               let fatDouble = Double(fat),
               let gramsDouble = Double(grams),
               !mealType.isEmpty,
               !name.isEmpty {
                let adjustedCalories = Int((Double(calorieInt) * gramsDouble) / 100.0)
                let adjustedProtein = (proteinDouble * gramsDouble) / 100.0
                let adjustedCarbs = (carbsDouble * gramsDouble) / 100.0
                let adjustedFat = (fatDouble * gramsDouble) / 100.0
                
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
            isTextFieldFocused = false
            dismiss()
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddFoodView(viewModel: FoodViewModel())
}

import SwiftUI

struct FoodRowView: View {
    var food: FoodItem
    @ObservedObject var viewModel: FoodViewModel
    
    @State private var isExpanded: Bool = false
    @State private var gramsInput: String = ""
    @State private var mealType: String = "Breakfast"
    
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Ensures proper stacking
            HStack {
                Text(food.name)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "plus.circle")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)

            // Expanded Section (Already present but collapsed)
            VStack(spacing: 8) {
                TextField("Grams Consumed", text: $gramsInput)
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

                ExpandingButton(title: "Add") {
                    guard let gramsValue = Double(gramsInput.replacingOccurrences(of: ",", with: ".")) else {
                        return
                    }
                    viewModel.addPredefinedFood(food: food, gramsConsumed: gramsValue, mealType: mealType)
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded = false
                    }
                    gramsInput = ""
                    mealType = "Breakfast"
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(8)
            .frame(maxHeight: isExpanded ? nil : 0) // Prevents appearing from nowhere
            .opacity(isExpanded ? 1 : 0) // Prevents flickering
            .clipped() // Hides content when collapsed

            Divider().background(Color.black)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1), value: isExpanded)
    }
}

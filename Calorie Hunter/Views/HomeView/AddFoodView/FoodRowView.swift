import SwiftUI

struct FoodRowView: View {
    var food: FoodItem
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    let mealType: String  // Meal type passed from parent

    @State private var isExpanded: Bool = false
    @State private var gramsInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row with food name and expand button
            HStack {
                Text(food.name)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))

                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "plus.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 22))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color.black : Color.white)
            
            // Expanded section for entering grams
            VStack(spacing: 8) {
                TextField("Grams Consumed", text: $gramsInput)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                
                ExpandingButton(title: "Add") {
                    guard let gramsValue = Double(gramsInput.replacingOccurrences(of: ",", with: ".")) else {
                        return
                    }
                    // Use the preset mealType passed from the parent
                    viewModel.addPredefinedFood(food: food, gramsConsumed: gramsValue, mealType: mealType)
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                        isExpanded = false
                    }
                    gramsInput = ""
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(8)
            .frame(maxHeight: isExpanded ? nil : 0) // Expand/collapse the section
            .opacity(isExpanded ? 1 : 0)
            .clipped()
            
            Divider().background(colorScheme == .dark ? Color.black : Color.white)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1), value: isExpanded)
        .padding(.horizontal)
    }
}

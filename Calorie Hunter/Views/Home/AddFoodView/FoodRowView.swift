import SwiftUI

/// A single food row that can expand to log grams consumed.
struct FoodRowView<VM: FoodAddingViewModel>: View {
    let food: FoodItem
    @ObservedObject var viewModel: VM
    let mealType: String

    @State private var isExpanded = false
    @State private var gramsInput = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(food.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "plus.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            VStack(spacing: 8) {
                TextField("Grams Consumed", text: $gramsInput)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)

                Button("Add") {
                    guard let gramsValue = Double(gramsInput.replacingOccurrences(of: ",", with: ".")) else { return }
                    viewModel.logConsumption(of: food, grams: gramsValue, mealType: mealType)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                    gramsInput = ""
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .frame(maxHeight: isExpanded ? .none : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()

            Divider().background(Color(.systemBackground))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .padding(.horizontal)
    }
}

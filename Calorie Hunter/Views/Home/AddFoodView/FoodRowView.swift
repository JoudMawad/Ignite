import SwiftUI
import UIKit

/// A single food row that can expand to log grams consumed.
struct FoodRowView<VM: FoodAddingViewModel>: View {
    let food: FoodItem
    @ObservedObject var viewModel: VM
    @Environment(\.colorScheme) var colorScheme
    let mealType: String
    /// Controls whether the row is initially expanded
    var isExpanded: Bool = false

    /// Haptic feedback generator for add action.
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    @State private var expanded: Bool
    @State private var gramsInput = ""

    init(
        food: FoodItem,
        viewModel: VM,
        mealType: String,
        isExpanded: Bool = false
    ) {
        self.food = food
        self.viewModel = viewModel
        self.mealType = mealType
        self.isExpanded = isExpanded
        _expanded = State(initialValue: isExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(food.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        expanded.toggle()
                    }
                } label: {
                    Image(systemName: expanded ? "chevron.up" : "plus.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.clear))

            VStack(spacing: 8) {
                TextField("Grams Consumed", text: $gramsInput)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.clear))
                    .cornerRadius(8)
                
                Button(action: {
                    guard let gramsValue = Double(gramsInput.replacingOccurrences(of: ",", with: ".")) else {
                        feedbackGenerator.notificationOccurred(.error)
                        return
                    }
                    viewModel.logConsumption(of: food, grams: gramsValue, mealType: mealType)
                    // Always play success haptic after logging consumption
                    feedbackGenerator.notificationOccurred(.success)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        expanded = false
                    }
                    gramsInput = ""
                }){
                    
                    Label("Add", systemImage: "plus")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(20)
                        .background(Color.primary)
                        .foregroundColor( colorScheme == .dark ? .black : .white)
                        .clipShape(Capsule())
                    
                }
            }
            .padding()
            .background(Color(.clear))
            .cornerRadius(8)
      .frame(maxHeight: expanded ? .none : 0)
            .opacity(expanded ? 1 : 0)
            .clipped()
            
                
                
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: expanded)
        .padding(.horizontal)
    }
}

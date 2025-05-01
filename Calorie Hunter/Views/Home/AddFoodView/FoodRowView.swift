import SwiftUI
import UIKit

/// A single food row that can expand to log grams consumed.
struct FoodRowView<VM: FoodAddingViewModel>: View {
    let food: FoodItem
    @ObservedObject var viewModel: VM
    @Environment(\.colorScheme) var colorScheme
    let mealType: String

    /// Haptic feedback generator for add action.
    private let feedbackGenerator = UINotificationFeedbackGenerator()

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
                        isExpanded = false
                    }
                    gramsInput = ""
                }){
                    
                    Label("Add", systemImage: "plus")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.primary)
                        .foregroundColor( colorScheme == .dark ? .black : .white)
                        .clipShape(Capsule())
                    
                }
            }
            .padding()
            .background(Color(.clear))
            .cornerRadius(8)
            .frame(maxHeight: isExpanded ? .none : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()
                
                
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .padding(.horizontal)
    }
}

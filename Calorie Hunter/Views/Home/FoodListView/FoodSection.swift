import SwiftUI
import UIKit

struct FoodSection: View {
    // ViewModel to access food data and actions.
    @ObservedObject var viewModel: FoodViewModel
    // Adapt UI styling based on the system color scheme.
    @Environment(\.colorScheme) var colorScheme
    // The meal type for this section (e.g., Breakfast, Lunch).
    let mealType: String
    // Binding to track which sections are expanded.
    @Binding var expandedSections: Set<String>
    
    // Closure triggered when the plus icon is tapped to add a new food.
    var addFoodAction: (String) -> Void

    // State to track if the section is in edit mode.
    @State private var isEditing = false

    /// Haptic feedback generator for the Edit button.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)
    /// Also used for the Add button haptic feedback.

    /// Filters only user‐added foods for this meal type eaten today.
    var filteredItems: [FoodItem] {
        viewModel.foodItems.filter { food in
            food.isUserAdded
            && food.mealType == mealType
            && isFoodFromToday(food.date)
        }
    }

    /// Check if the section for this meal type is currently expanded.
    var isExpanded: Bool {
        expandedSections.contains(mealType)
    }
    
    /// Helper to check if a given date is today.
    private func isFoodFromToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Calculate the total calories for the given meal type.
    var totalCalories: Int {
        viewModel.totalCaloriesForMealType(mealType)
    }
    
    /// Convenience array of filtered items for this section.
    private var items: [FoodItem] {
        filteredItems
    }

    /// Header view for this food section.
    private var headerView: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: isExpanded)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            Text(mealType)
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Spacer()
            if !isExpanded {
                Text("\(totalCalories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if isExpanded && !items.isEmpty {
                Button(action: {
                    tapFeedback.impactOccurred()
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primary)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .clipShape(Capsule())
                }
                .padding(.trailing, 5)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeOut(duration: 0.3), value: isExpanded)
            }
            Button(action: {
                tapFeedback.impactOccurred()
                addFoodAction(mealType)
            }) {
                Label("Add", systemImage: "plus")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.primary)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .clipShape(Capsule())
            }
            .padding(.trailing, 5)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            headerView
                .padding(.vertical, 10)
                .background(Color.clear)
                .onTapGesture {
                    withAnimation {
                        if isExpanded {
                            expandedSections.remove(mealType)
                            isEditing = false
                        } else {
                            expandedSections.insert(mealType)
                        }
                    }
                }
            
            // Content
            if isExpanded {
                sectionContent // << Move content to a private property
            }
        }
        .background(Color.clear)
        .padding(.horizontal)
    }

    private var sectionContent: some View {
        if items.isEmpty {
            return AnyView(
                Text("No entries yet")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        } else {
            let displayedItems = Array(items.enumerated()) // Break up computation

            return AnyView(
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(displayedItems, id: \.element.id) { index, food in
                        HStack {
                            FoodRow(food: food)
                            Spacer()
                            if isEditing {
                                Button(action: { viewModel.removeFood(by: food.id) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            )
        }
    }
    /// Opens the AddFoodView for the specified meal type.
    /// (Note: This helper is currently unused because addFoodAction is passed from the parent.)
    private func openAddFoodView(for mealType: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            // Initialize AddFoodView with the meal type preset.
            let addFoodView = AddFoodView(viewModel: viewModel, preselectedMealType: mealType)
            let hostingController = UIHostingController(rootView: addFoodView)
            keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }
}

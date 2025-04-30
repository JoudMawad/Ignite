import SwiftUI
import CoreData

struct DateFoodSectionsView: View {
    let date: Date
    @StateObject private var viewModel: DateFoodViewModel
    @Environment(\.managedObjectContext) private var context
    @Namespace private var cardNamespace
    @Environment(\.colorScheme) var colorScheme
    @State private var expandedSections: Set<String> = []
    @State private var showingAddFoodSheet = false
    @State private var selectedMealType: String? = nil
    private let sectionNames = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    @ViewBuilder
    private func sectionCard(mealType: String) -> some View {
        let itemsForSection = viewModel.foodEntries.filter { $0.mealType == mealType }
        let sectionCalories = itemsForSection.reduce(0) { $0 + $1.calories }
        let isExpanded = expandedSections.contains(mealType)

        SectionCardView(
            mealType: mealType,
            namespace: cardNamespace,
            items: itemsForSection,
            calories: sectionCalories,
            isExpanded: isExpanded,
            onToggle: { toggle(mealType) },
            onRemove: { viewModel.removeFood(by: $0) },
            onAdd: {
              selectedMealType = mealType
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? nil : 100)
    }

    init(date: Date, context: NSManagedObjectContext) {
        self.date = date
        _viewModel = StateObject(wrappedValue: DateFoodViewModel(date: date, context: context))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sectionNames, id: \.self) { meal in
                    sectionCard(mealType: meal)
                }
            }
            .padding()
        }
        .sheet(item: $selectedMealType) { meal in
          AddFoodForDateView(
            viewModel: viewModel,
            preselectedMealType: meal
          )
          .environment(\.managedObjectContext, context)
        }
    }

     func toggle(_ mealType: String) {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
            if expandedSections.contains(mealType) {
                expandedSections.remove(mealType)
            } else {
                expandedSections.insert(mealType)
            }
        }
    }
}

struct SectionCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let mealType: String
    let namespace: Namespace.ID
    let items: [FoodItem]
    let calories: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    let onRemove: (UUID) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack {
                Spacer()
                Text(mealType)
                    .font(.system(size: 20, weight: .bold))
                Text("\(calories) kcal")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                Button(action: onToggle) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: isExpanded)
                        .tint(Color.primary)
                }
                Spacer()
            }
            .padding(.horizontal)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(items, id: \.id) { item in
                        HStack {
                            FoodRow(food: item)
                            Spacer()
                            Button {
                                onRemove(item.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }
                    HStack {
                        Spacer()
                        Button(action: onAdd) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Food")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                        Spacer()
                    }
                }
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .matchedGeometryEffect(id: mealType, in: namespace)
                .shadow(radius: 3)
        )
        
    }
    
    
}
// MARK: - Previews
struct DateFoodSectionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Use an in-memory or shared Core Data context
        let context = PersistenceController.shared.container.viewContext
        DateFoodSectionsView(date: Date(), context: context)
            .environment(\.managedObjectContext, context)
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

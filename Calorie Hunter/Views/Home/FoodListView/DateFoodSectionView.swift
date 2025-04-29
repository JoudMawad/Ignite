import SwiftUI
import CoreData

struct DateFoodSectionsView: View {
    let date: Date
    @StateObject private var viewModel: DateFoodViewModel
    @Environment(\.managedObjectContext) private var context
    @State private var expandedSections: Set<String> = []
    @State private var showingAddFoodSheet = false
    @State private var selectedMealType = ""

    init(date: Date, context: NSManagedObjectContext) {
        self.date = date
        _viewModel = StateObject(wrappedValue: DateFoodViewModel(date: date, context: context))
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(["Breakfast", "Lunch", "Dinner", "Snack"], id: \.self) { mealType in
                // Filter entries added under this section
                let itemsForSection = viewModel.foodEntries.filter { $0.mealType == mealType }
                // Total calories for this section
                let sectionCalories = itemsForSection.reduce(0) { $0 + $1.calories }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(mealType)
                            .font(.headline)
                        Spacer()
                        Text("\(sectionCalories) kcal")
                            .foregroundColor(.gray)
                        Button {
                            toggle(mealType)
                        } label: {
                            Image(systemName: expandedSections.contains(mealType) ? "chevron.up" : "chevron.down")
                                .font(.system(size: 18))
                        }
                    }
                    .padding(.horizontal)

                    if expandedSections.contains(mealType) {
                        VStack(spacing: 6) {
                            ForEach(itemsForSection, id: \.id) { item in
                                HStack {
                                    FoodRow(food: item)
                                    Spacer()
                                    Button {
                                        viewModel.removeFood(by: item.id)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            HStack {
                                Spacer()
                                Button {
                                    selectedMealType = mealType
                                    showingAddFoodSheet = true
                                } label: {
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
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 2)
                )
                .animation(.easeInOut, value: expandedSections)
            }
        }
        .padding()
        .sheet(isPresented: $showingAddFoodSheet) {
            AddFoodForDateView(
                viewModel: viewModel,
                preselectedMealType: selectedMealType
            )
            .environment(\.managedObjectContext, context)
        }
    }

    private func toggle(_ mealType: String) {
        if expandedSections.contains(mealType) {
            expandedSections.remove(mealType)
        } else {
            expandedSections.insert(mealType)
        }
    }
}

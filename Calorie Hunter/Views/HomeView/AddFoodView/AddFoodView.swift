import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    var preselectedMealType: String
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    @State private var selectedMealType: String

    init(viewModel: FoodViewModel, preselectedMealType: String) {
        self.viewModel = viewModel
        self.preselectedMealType = preselectedMealType
        _selectedMealType = State(initialValue: preselectedMealType)
    }
    
    // MARK: - Data Filtering
    private var combinedFoods: [FoodItem] {
        PredefinedFoods.foods + PredefinedUserFoods.shared.foods
    }
    
    private var filteredFoods: [FoodItem] {
        if searchText.isEmpty {
            return combinedFoods
        } else {
            return combinedFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Subviews
    private var searchBar: some View {
        TextField("Search food...", text: $searchText)
            .padding(10)
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: Color.primary.opacity(0.25), radius: 8)
            )
            .padding(.horizontal, 30)
            .padding(.top, 25)
            .padding(.bottom, 9)
    }
    
    private var foodList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(filteredFoods, id: \.id) { food in
                    FoodRowView(food: food, viewModel: viewModel, mealType: preselectedMealType)
                   
                        .background(colorScheme == .dark ? Color.black : Color.white)
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 550)
    }
    
    private var manualEntryButton: some View {
        ExpandingButton(title: "Manual Entry") {
            withAnimation {
                isManualEntryPresented = true
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 8)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background content remains intact
                VStack {
                    Text("Add Food")
                        .font(.system(size: 33, weight: .bold, design: .default))
                        .padding(.trailing, 220)
                        .padding(.top, 30)
                    
                        
                    searchBar
                        .padding(.horizontal, 30)
                        .padding(.top, -19)
                        .padding(.bottom, 5)
                    if !filteredFoods.isEmpty {
                        foodList
                    }
                    Spacer()
                    manualEntryButton
                }
                
                .background(colorScheme == .dark ? Color.black : Color.white)
                
                
                // Overlay: Only the ManualEntryView card slides up
                if isManualEntryPresented {
                    // Dimmed background (tapping dismisses the card)
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isManualEntryPresented = false
                            }
                        }
                    
                    // The card slides up from the bottom with horizontal padding
                    ManualEntryView(viewModel: viewModel)
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: isManualEntryPresented)
                }
            }
        }

    }
    
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(viewModel: FoodViewModel(), preselectedMealType: "Breakfast")
    }
}

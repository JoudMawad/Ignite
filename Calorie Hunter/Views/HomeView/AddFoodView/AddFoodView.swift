import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    var preselectedMealType: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var keyboardManager = KeyboardManager()

    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    // Start the card offscreen (cardOffset equals screen height)
    @State private var cardOffset: CGFloat = UIScreen.main.bounds.height
    @State private var overlayOpacity: Double = 0.25
    @State private var selectedMealType: String

    init(viewModel: FoodViewModel, preselectedMealType: String) {
        self.viewModel = viewModel
        self.preselectedMealType = preselectedMealType
        _selectedMealType = State(initialValue: preselectedMealType)
    }
    
    // Computed property for dynamic blur based on the card's offset.
    // When cardOffset is UIScreen.main.bounds.height, blur is 0.
    // When cardOffset is 0, blur is maxBlur.
    private var dynamicBlur: CGFloat {
        guard isManualEntryPresented else { return 0 }
        let maxBlur: CGFloat = 5
        return maxBlur * (1 - cardOffset / UIScreen.main.bounds.height)
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
            presentManualEntry()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 8)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content with dynamic blur applied.
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
                .blur(radius: dynamicBlur)
                .clipped()
                
                // Overlay for Manual Entry
                if isManualEntryPresented {
                    Color.black.opacity(overlayOpacity)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissManualEntry()
                        }
                    
                    ManualEntryView(viewModel: viewModel, onSuccessfulDismiss: {
                        dismissManualEntry()
                    })
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    // Combine your custom offset with the keyboard height
                    .offset(y: cardOffset - keyboardManager.keyboardHeight)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }
    
    // MARK: - Animation Functions
    
    // Present the manual entry view immediately with a slide-up animation and increasing blur.
    private func presentManualEntry() {
        // Start offscreen.
        cardOffset = UIScreen.main.bounds.height
        overlayOpacity = 0.25  // or your initial value

        // Insert the view.
        isManualEntryPresented = true

        // Animate after a slight delay, allowing the transition to complete.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 1)) {
                cardOffset = 0
            }
            withAnimation(.easeIn(duration: 0.8)) {
                overlayOpacity = 0.5
            }
        }
    }
    
    // Dismiss the manual entry view with a slide-down animation and decreasing blur.
    private func dismissManualEntry() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 1)) {
            cardOffset = UIScreen.main.bounds.height
            overlayOpacity = 0.0
        }
        // Remove the manual entry view after the animation completes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isManualEntryPresented = false
        }
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(viewModel: FoodViewModel(), preselectedMealType: "Breakfast")
    }
}

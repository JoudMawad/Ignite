import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    var preselectedMealType: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var keyboardManager = KeyboardManager()

    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    // The card will start offscreen. viewHeight is used instead of UIScreen bounds.
    @State private var cardOffset: CGFloat = 0
    @State private var overlayOpacity: Double = 0.25
    @State private var selectedMealType: String
    @State private var viewHeight: CGFloat = 0  // will be updated from GeometryReader
    @State private var cardHorizontalOffset: CGFloat = -30


    init(viewModel: FoodViewModel, preselectedMealType: String) {
        self.viewModel = viewModel
        self.preselectedMealType = preselectedMealType
        _selectedMealType = State(initialValue: preselectedMealType)
    }
    
    // Dynamic blur based on cardOffset relative to the actual view height.
    private var dynamicBlur: CGFloat {
        guard isManualEntryPresented, viewHeight > 0 else { return 0 }
        let maxBlur: CGFloat = 5
        return maxBlur * (1 - cardOffset / viewHeight)
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
            .padding(.top, 25)
            .padding(.bottom, 9)
            .padding(.horizontal, 23)
            .padding(.trailing, 3)
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
            
        }
        .frame(maxHeight: 550)
        
    }
    
    private var manualEntryButton: some View {
        ExpandingButton(title: "Manual Entry") {
            presentManualEntry()
        }
        .padding(.bottom, 8)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Main content with dynamic blur applied.
                    VStack {
                        Text("Add Food")
                            .font(.system(size: 33, weight: .bold, design: .default))
                            .padding(.top, 30)
                            .padding(.trailing, 210)
                        
                        searchBar
                            .padding(.top, -19)
                            .padding(.bottom, 5)
                        
                        if !filteredFoods.isEmpty {
                            foodList
                        }
                        
                        Spacer()
                        manualEntryButton
                    }
                    // Ensure the VStack takes the full available width and is centered.
                    .frame(width: geometry.size.width)
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
                        .frame(height: viewHeight * 0.68)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        // Adjust the offset with the current keyboard height.
                        .offset( y: cardOffset - keyboardManager.keyboardHeight)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .onAppear {
                    // Set viewHeight from the available geometry and position the card offscreen.
                    viewHeight = geometry.size.height
                    cardOffset = viewHeight
                }
                .frame(width: geometry.size.width)

            }
            .navigationBarHidden(true)
            
        }
    }
    
    // MARK: - Animation Functions
    
    // Present the manual entry view with a slide-up animation.
    private func presentManualEntry() {
        // Start with the card offscreen.
        cardOffset = viewHeight
        overlayOpacity = 0.25

        isManualEntryPresented = true

        // Animate after a slight delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 1)) {
                cardOffset = 0
            }
            withAnimation(.easeIn(duration: 0.8)) {
                overlayOpacity = 0.5
            }
        }
    }
    
    // Dismiss the manual entry view with a slide-down animation.
    private func dismissManualEntry() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 1)) {
            cardOffset = viewHeight
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

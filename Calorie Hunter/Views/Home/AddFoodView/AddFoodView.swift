import SwiftUI

struct AddFoodView: View {
    // ViewModel for handling food data.
    @ObservedObject var viewModel: FoodViewModel
    // Use the system color scheme to adjust colors accordingly.
    @Environment(\.colorScheme) var colorScheme
    // Preselected meal type passed from the parent view.
    var preselectedMealType: String
    // Environment value to dismiss the view.
    @Environment(\.dismiss) var dismiss
    // Manage keyboard-related behavior.
    @StateObject private var keyboardManager = KeyboardManager()

    // Local state for search text input.
    @State private var searchText: String = ""
    // State to control whether the manual entry view is presented.
    @State private var isManualEntryPresented: Bool = false
    // The card starts offscreen; viewHeight (from GeometryReader) is used to compute offsets.
    @State private var cardOffset: CGFloat = 0
    // Opacity for the overlay behind the manual entry view.
    @State private var overlayOpacity: Double = 0.25
    // Track the selected meal type; initially set from the preselected value.
    @State private var selectedMealType: String
    // Store the available view height, which will be updated via GeometryReader.
    @State private var viewHeight: CGFloat = 0
    // Horizontal offset for the card; used for visual adjustment.
    @State private var cardHorizontalOffset: CGFloat = -30

    // Initialize with a FoodViewModel and preselected meal type.
    init(viewModel: FoodViewModel, preselectedMealType: String) {
        self.viewModel = viewModel
        self.preselectedMealType = preselectedMealType
        // Set the selected meal type to the preselected value.
        _selectedMealType = State(initialValue: preselectedMealType)
    }
    
    /// Computes a dynamic blur value for the main content based on the card's vertical offset.
    /// The further the card moves (relative to viewHeight), the less blur is applied.
    private var dynamicBlur: CGFloat {
        guard isManualEntryPresented, viewHeight > 0 else { return 0 }
        let maxBlur: CGFloat = 5
        return maxBlur * (1 - cardOffset / viewHeight)
    }
    
    // MARK: - Data Filtering
    /// Combine predefined foods with user-added foods.
    private var combinedFoods: [FoodItem] {
        PredefinedFoods.foods + PredefinedUserFoods.shared.foods
    }
    
    /// Filter the combined food items based on the search text.
    /// If the search text is empty, return all items; otherwise, filter by name.
    private var filteredFoods: [FoodItem] {
        if searchText.isEmpty {
            return combinedFoods
        } else {
            return combinedFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Subviews
    /// A search bar view with padding, rounded background, and shadow.
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
    
    /// A scrollable list of food items displayed as rows.
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
    
    /// A button to trigger the manual entry view.
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
                    // Main content of the view.
                    VStack {
                        // Title at the top of the view.
                        Text("Add Food")
                            .font(.system(size: 33, weight: .bold, design: .default))
                            .padding(.top, 30)
                            .padding(.trailing, 210)
                        
                        // The search bar allows the user to filter food items.
                        searchBar
                            .padding(.top, -19)
                            .padding(.bottom, 5)
                        
                        // Only display the food list if there are results.
                        if !filteredFoods.isEmpty {
                            foodList
                        }
                        
                        Spacer()
                        // Button to present manual entry of food.
                        manualEntryButton
                    }
                    // Ensure the content takes full width and apply dynamic blur.
                    .frame(width: geometry.size.width)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .blur(radius: dynamicBlur)
                    .clipped()
                    
                    // Overlay for manual entry.
                    if isManualEntryPresented {
                        // Dimmed background overlay that dismisses manual entry on tap.
                        Color.black.opacity(overlayOpacity)
                            .ignoresSafeArea()
                            .onTapGesture {
                                dismissManualEntry()
                            }
                        
                        // The manual entry view itself.
                        ManualEntryView(viewModel: viewModel, onSuccessfulDismiss: {
                            dismissManualEntry()
                        })
                        .frame(height: viewHeight * 0.68)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        // Offset is adjusted based on the current keyboard height.
                        .offset(y: cardOffset - keyboardManager.keyboardHeight)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .onAppear {
                    // Set the view height based on available geometry and position the card offscreen.
                    viewHeight = geometry.size.height
                    cardOffset = viewHeight
                }
                .frame(width: geometry.size.width)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Animation Functions
    
    /// Presents the manual entry view with a slide-up animation.
    private func presentManualEntry() {
        // Begin with the card positioned offscreen.
        cardOffset = viewHeight
        overlayOpacity = 0.25
        isManualEntryPresented = true

        // After a slight delay, animate the card sliding up and increase the overlay opacity.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 1)) {
                cardOffset = 0
            }
            withAnimation(.easeIn(duration: 0.8)) {
                overlayOpacity = 0.5
            }
        }
    }
    
    /// Dismisses the manual entry view with a slide-down animation.
    private func dismissManualEntry() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 1)) {
            cardOffset = viewHeight
            overlayOpacity = 0.0
        }
        // After the animation, hide the manual entry view.
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

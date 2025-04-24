import SwiftUI

struct AddFoodView: View {
    // MARK: - Dependencies
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var preselectedMealType: String
    @StateObject private var keyboardManager = KeyboardManager()

    // MARK: - Scanning State
    @State private var isShowingScanner = false
    @State private var scannedCode: String? = nil

    // MARK: - View State
    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var overlayOpacity: Double = 0.25
    @State private var viewHeight: CGFloat = 0

    // MARK: - Initialization
    init(viewModel: FoodViewModel, preselectedMealType: String) {
        self.viewModel = viewModel
        self.preselectedMealType = preselectedMealType
    }

    // MARK: - Computed Collections
    private var combinedFoods: [FoodItem] {
        PredefinedFoods.foods + PreDefinedUserFoods.shared.foods
    }
    private var filteredFoods: [FoodItem] {
        if let code = scannedCode, !code.isEmpty,
           let found = viewModel.findFoodByBarcode(code) {
            return [found]
        }
        if searchText.isEmpty {
            return combinedFoods
        }
        return combinedFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Title
                    Text("Add Food")
                        .font(.system(size: 33, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 23)
                        .padding(.top, 30)

                    // Search Bar Card (expandable)
VStack(spacing: 0) {
    HStack(spacing: 0) {
        TextField("Search food...", text: $searchText, onEditingChanged: { _ in scannedCode = nil })
            .padding(.vertical, 10)
            .padding(.horizontal, 16)

        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isShowingScanner.toggle()
            }
        }) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 20))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
        }
    }
    .frame(maxWidth: .infinity)
    .background(Color.clear)

    if isShowingScanner {
        VStack(spacing: 12) {
            Text("Align barcode in the box")
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            BarcodeScannerView { code in
                handleScanned(code)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .shadow(color: Color.primary.opacity(0.15), radius: 6, x: 0, y: 2)
)
.padding(.horizontal, 23)
.padding(.top, 25)
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowingScanner)

// Food List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredFoods, id: \.id) { food in
                                FoodRowView(food: food,
                                            viewModel: viewModel,
                                            mealType: preselectedMealType)
                                    .background(colorScheme == .dark ? Color.black : Color.white)
                            }
                        }
                        .padding(.horizontal, 23)
                        .padding(.top, isShowingScanner ? 13 : 13)
                    }
                    .frame(maxHeight: 550)

                    Spacer()

                    // Manual Entry Button
                    ExpandingButton(title: "Manual Entry") {
                        presentManualEntry()
                    }
                    .padding(.horizontal, 23)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .blur(radius: isManualEntryPresented ? 5 : 0)
                .animation(.spring(), value: isShowingScanner)
                .onAppear {
                    viewHeight = geometry.size.height
                    cardOffset = viewHeight
                }

                // Manual Entry Overlay
                if isManualEntryPresented {
                    Color.black.opacity(overlayOpacity)
                        .ignoresSafeArea()
                        .onTapGesture { dismissManualEntry() }

                    ManualEntryView(viewModel: viewModel, scannedBarcode: scannedCode, onSuccessfulDismiss: {
                        dismissManualEntry()
                        scannedCode = nil
                    })
                    .frame(height: viewHeight * 1.6)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .offset(y: cardOffset - keyboardManager.keyboardHeight + 50)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Scanning Handler
    private func handleScanned(_ code: String) {
        if viewModel.findFoodByBarcode(code) != nil {
            scannedCode = code
        } else {
            scannedCode = code
            presentManualEntry()
        }
        withAnimation(.spring()) { isShowingScanner = false }
    }

    // MARK: - Manual Entry Animations
    private func presentManualEntry() {
        overlayOpacity = 0.25
        isManualEntryPresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8)) {
                cardOffset = 0
            }
            withAnimation(.easeIn(duration: 0.8)) {
                overlayOpacity = 0.5
            }
        }
    }

    private func dismissManualEntry() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8)) {
            cardOffset = viewHeight
            overlayOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isManualEntryPresented = false
        }
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(viewModel: FoodViewModel(), preselectedMealType: "Breakfast")
    }
}

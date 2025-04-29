// AddFoodView.swift
import SwiftUI
import CoreData

struct AddFoodView: View {
    // MARK: - Dependencies
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var preselectedMealType: String
    @StateObject private var keyboardManager = KeyboardManager()

    // MARK: - Usage Counts
    /// Number of times each food item has been added, based on viewModel.foodItems
    private var usageCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for item in viewModel.foodItems {
            counts[item.name, default: 0] += 1
        }
        return counts
    }

    // MARK: - Scanning State
    @State private var isShowingScanner = false
    @State private var scannedCode: String? = nil

    // MARK: - View State
    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var overlayOpacity: Double = 0.25
    @State private var viewHeight: CGFloat = 0
    @State private var searchTask: Task<(), Never>? = nil

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntity.name, ascending: true)],
      animation: .default
    )
    private var foodEntities: FetchedResults<FoodEntity>

    // MARK: - Computed Collections
    /// All available foods (predefined + user-added) fetched from Core Data.
    private var combinedFoods: [FoodItem] {
        foodEntities.map { entity in
            FoodItem(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                calories: Int(entity.calories),
                protein: entity.protein,
                carbs: entity.carbs,
                fat: entity.fat,
                grams: entity.grams,
                mealType: entity.mealType ?? "",
                date: entity.date ?? Date(),
                isUserAdded: entity.isUserAdded,
                barcode: entity.barcode
            )
        }
    }

    // MARK: - Filtered Foods
    /// Applies search text, scanned code, and usage counts to the combined foods list.
    private var filteredFoods: [FoodItem] {
        // Determine the base list
        let baseList: [FoodItem]
        if let product = viewModel.currentProduct {
            // Show the recently fetched product
            baseList = [product]
        } else if let code = scannedCode, !code.isEmpty,
                  let local = viewModel.findFoodByBarcode(code) {
            // Show local match for scanned barcode
            baseList = [local]
        } else if !searchText.isEmpty {
            // Filter by search text
            baseList = combinedFoods.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            // Default to full list
            baseList = combinedFoods
        }
        // Sort by usage count descending, then name ascending
        return baseList.sorted {
            let countA = usageCounts[$0.name] ?? 0
            let countB = usageCounts[$1.name] ?? 0
            if countA != countB {
                return countA > countB
            } else {
                return $0.name < $1.name
            }
        }
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
                            TextField("Search food...", text: $searchText)
                                .submitLabel(.search)
                                .onSubmit {
                                    viewModel.currentProduct = nil
                                }
                                .onChange(of: searchText) { _, _ in
                                    viewModel.currentProduct = nil
                                    scannedCode = nil
                                    viewModel.errorMessage = nil
                                }
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

                    // Fetched Product Quantity Input
                    if let product = viewModel.currentProduct,
                       !combinedFoods.contains(where: { $0.barcode == product.barcode }) {
                        FoodRowView(food: product, viewModel: viewModel, mealType: preselectedMealType)
                            .padding(.horizontal, 23)
                            .padding(.top, 13)
                    }

                    // API Lookup Error
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal, 23)
                            .padding(.vertical, 8)
                    }

                    // Food List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredFoods, id: \.id) { food in
                                FoodRowView(food: food, viewModel: viewModel, mealType: preselectedMealType)
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

                    ManualEntryView(
                        viewModel: FoodListViewModel(context: context),
                        scannedBarcode: scannedCode,
                        onSuccessfulDismiss: {
                            dismissManualEntry()
                            scannedCode = nil
                        }
                    )
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
        withAnimation(.spring()) { isShowingScanner = false }
        viewModel.currentProduct = nil
        viewModel.errorMessage = nil
        searchText = ""
        if let _ = viewModel.findFoodByBarcode(code) {
            scannedCode = code
            return
        }
        Task {
            await viewModel.fetchProduct(barcode: code)
            if viewModel.currentProduct != nil {
                scannedCode = code
            } else {
                scannedCode = code
                presentManualEntry()
            }
        }
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
        AddFoodView(
            viewModel: FoodViewModel(context: PersistenceController.shared.container.viewContext),
            preselectedMealType: "Breakfast"
        )
    }
}

// AddFoodView.swift
import SwiftUI
import CoreData
import UIKit

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
    @State private var expandedFoodID: UUID? = nil

    // MARK: - View State
    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var overlayOpacity: Double = 0.25
    @State private var viewHeight: CGFloat = 0
    @State private var searchTask: Task<(), Never>? = nil
    /// Haptic feedback generators for barcode scanning results.
    private let successFeedback = UINotificationFeedbackGenerator()
    private let errorFeedback   = UINotificationFeedbackGenerator()

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
        // Sorting closure by usage count and name
        let sortByUsageAndName: (FoodItem, FoodItem) -> Bool = { a, b in
            let countA = usageCounts[a.name] ?? 0
            let countB = usageCounts[b.name] ?? 0
            if countA != countB {
                return countA > countB
            } else {
                return a.name < b.name
            }
        }

        // If an API product is present, show it first
        if let product = viewModel.currentProduct {
            let rest = combinedFoods.filter { $0.id != product.id }
            return [product] + rest.sorted(by: sortByUsageAndName)
        }
        // If a scanned barcode matches a local item, show it first
        else if let code = scannedCode, !code.isEmpty,
                  let local = viewModel.findFoodByBarcode(code) {
            let rest = combinedFoods.filter { $0.id != local.id }
            return [local] + rest.sorted(by: sortByUsageAndName)
        }
        // If the user is typing search text, filter and sort
        else if !searchText.isEmpty {
            let baseList = combinedFoods.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            return baseList.sorted(by: sortByUsageAndName)
        }
        // Default: full list sorted by usage and name
        else {
            return combinedFoods.sorted(by: sortByUsageAndName)
        }
    }

    // MARK: - Pagination State
    @State private var displayedFoods: [FoodItem] = []
    private let batchSize = 20

    private func resetDisplayedFoods() {
        displayedFoods = Array(filteredFoods.prefix(batchSize))
    }

    private func loadMoreFoodsIfNeeded(currentItem: FoodItem) {
        guard let index = displayedFoods.firstIndex(where: { $0.id == currentItem.id }) else { return }
        // When the last displayed item appears, load the next batch
        if index == displayedFoods.count - 1 {
            let nextIndex = displayedFoods.count
            let endIndex = min(filteredFoods.count, nextIndex + batchSize)
            if nextIndex < endIndex {
                displayedFoods.append(contentsOf: filteredFoods[nextIndex..<endIndex])
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

                    // MARK: - Food List with Pagination
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(displayedFoods, id: \.id) { food in
                                FoodRowView(
                                    food: food,
                                    viewModel: viewModel,
                                    mealType: preselectedMealType,
                                    isExpanded: food.id == expandedFoodID
                                )
                                    .background(colorScheme == .dark ? Color.black : Color.white)
                                    .onAppear {
                                        loadMoreFoodsIfNeeded(currentItem: food)
                                    }
                            }
                        }
                        .padding(.top, isShowingScanner ? 13 : 13)
                    }
                    .frame(maxHeight: 550)
                    .onAppear {
                        resetDisplayedFoods()
                    }
                    .onChange(of: searchText) {
                        resetDisplayedFoods()
                    }
                    .onChange(of: scannedCode) {
                        resetDisplayedFoods()
                    }
                    .onChange(of: viewModel.currentProduct) {
                        resetDisplayedFoods()
                    }

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
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }

    // MARK: - Scanning Handler
    private func handleScanned(_ code: String) {
        withAnimation(.spring()) { isShowingScanner = false }
        viewModel.currentProduct = nil
        viewModel.errorMessage = nil
        searchText = ""
        if let local = viewModel.findFoodByBarcode(code) {
            scannedCode = code
            expandedFoodID = local.id
            return
        }
        Task {
            await viewModel.fetchProduct(barcode: code)
            // Provide haptic feedback based on API result
            if viewModel.currentProduct != nil {
                successFeedback.notificationOccurred(.success)
            } else {
                errorFeedback.notificationOccurred(.error)
            }
            if let p = viewModel.currentProduct {
                scannedCode = code
                expandedFoodID = p.id
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

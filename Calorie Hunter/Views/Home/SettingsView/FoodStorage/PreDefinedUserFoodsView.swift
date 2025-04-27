import SwiftUI
import CoreData

struct PreDefinedFoodRow: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    var food: FoodItem
    @ObservedObject var viewModel: FoodListViewModel
    var onDelete: (() -> Void)? = nil
    @State private var isExpanded: Bool = false

    // Editable fields
    @State private var editName: String = ""
    @State private var editCalories: String = ""
    @State private var editProtein: String = ""
    @State private var editCarbs: String = ""
    @State private var editFat: String = ""
    @State private var editGrams: String = ""

    // Formatted nutritional strings
    private var proteinText: String { String(format: "%.1f", food.protein) }
    private var carbsText: String   { String(format: "%.1f", food.carbs) }
    private var fatText: String     { String(format: "%.1f", food.fat) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(food.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if isExpanded {
                            // Close expansion
                            isExpanded = false
                        } else {
                            // Initialize editable fields when opening
                            editName = food.name
                            editCalories = String(food.calories)
                            editProtein = String(food.protein)
                            editCarbs = String(food.carbs)
                            editFat = String(food.fat)
                            editGrams = String(food.grams)
                            isExpanded = true
                        }
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.primary)
                        .font(.system(size: 20))
                }
                .padding(.leading, 4)
                if isExpanded {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color.black : Color.white)

            // Expanded detail section
            if isExpanded {
                // Editable fields with improved UI
                VStack(alignment: .leading, spacing: 16) {
                    // Name field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Name", text: $editName)
                            .font(.body)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    // Nutrition fields in two columns
                    HStack(spacing: 12) {
                        // Calories
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0", text: $editCalories)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        // Protein
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protein (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editProtein)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    HStack(spacing: 12) {
                        // Carbs
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Carbs (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editCarbs)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        // Fat
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fat (g)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("0.0", text: $editFat)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    // Grams field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grams (g)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("0.0", text: $editGrams)
                            .keyboardType(.decimalPad)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    // Action buttons
                    HStack(spacing: 16) {
                        Button("Save") {
                            // existing save logic
                            guard
                                let cals = Int(editCalories),
                                let prot = Double(editProtein),
                                let carbsVal = Double(editCarbs),
                                let fatVal = Double(editFat),
                                let gramsVal = Double(editGrams)
                            else { return }
                            let updatedItem = FoodItem(
                                id: food.id,
                                name: editName,
                                calories: cals,
                                protein: prot,
                                carbs: carbsVal,
                                fat: fatVal,
                                grams: gramsVal,
                                mealType: food.mealType,
                                date: food.date,
                                isUserAdded: food.isUserAdded,
                                barcode: food.barcode
                            )
                            viewModel.updateFood(updatedItem)
                            isExpanded = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primary)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                        

                        Button("Delete") {
                            onDelete?()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()
                .background(colorScheme == .dark ? .black : .white)
                .cornerRadius(12)
            }
            
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

struct UserPreDefinedFoodsView: View {
    // Adapt UI styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    // View model managing the list of predefined (user-added) food items.
    @StateObject private var viewModel: FoodListViewModel
    // State to store the search text entered by the user.
    @State private var searchText = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String? = nil
    @State private var foodToEdit: FoodItem? = nil

    init() {
        _viewModel = StateObject(
            wrappedValue: FoodListViewModel(
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    // MARK: - Subviews for body
    private var headerView: some View {
        VStack {
            Text("Storage")
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 25)
                .padding(.trailing, 220)
                .padding(.top, 50)

            // --- Modern, expandable search bar card ---
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TextField("Search food...", text: $searchText)
                        .submitLabel(.search)
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
                            // When barcode is scanned:
                            searchText = ""
                            isShowingScanner = false
                            // Keep your original scannedCode logic
                            if let local = viewModel.foods.first(where: { $0.barcode == code }) {
                                scannedCode = local.barcode
                            }
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
            .padding(.bottom, 25)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowingScanner)
        }
    }

    private var foodsListView: some View {
        ScrollView {
            ForEach(Array(filteredFoods.enumerated()), id: \.element.id) { _, food in
                PreDefinedFoodRow(
                    food: food,
                    viewModel: viewModel,
                    onDelete: { viewModel.removeFood(by: food.id) }
                )
                Divider()
            }
        }
        .padding(.horizontal, 5)
        .scrollContentBackground(.hidden)
        .background(colorScheme == .dark ? .black : .white)
    }

    /// Filters the food items based on the search text.
    /// If searchText is empty, all foods are returned; otherwise, only those whose name contains the search text.
    var filteredFoods: [FoodItem] {
        if let code = scannedCode,
           let local = viewModel.foods.first(where: { $0.barcode == code }) {
            return [local]
        }
        if searchText.isEmpty {
            return viewModel.foods
        } else {
            return viewModel.foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                headerView
                foodsListView
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
        
    }
}

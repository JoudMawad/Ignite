import SwiftUI

/// A reusable search/scan/list UI that matches the original expandable search-bar style.
struct FoodSearchListView<VM: FoodAddingViewModel>: View {
    @ObservedObject var vm: VM
    @Binding var searchText: String
    @Binding var isShowingScanner: Bool
    @Binding var scannedCode: String?
    let mealType: String

    @Environment(\.colorScheme) var colorScheme

    /// Count usage frequency for sorting.
    private var usageCounts: [String:Int] {
        var counts: [String:Int] = [:]
        for item in vm.allFoods {
            counts[item.name, default: 0] += 1
        }
        return counts
    }

    /// Filtered and sorted foods based on search or scanned code.
    private var filteredFoods: [FoodItem] {
        let base: [FoodItem]
        if let product = vm.currentProduct {
            base = [product]
        } else if let code = scannedCode,
                  let local = vm.findFood(byBarcode: code) {
            base = [local]
        } else if !searchText.isEmpty {
            base = vm.allFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        } else {
            base = vm.allFoods
        }
        return base.sorted {
            let a = usageCounts[$0.name] ?? 0
            let b = usageCounts[$1.name] ?? 0
            if a != b { return a > b }
            return $0.name < $1.name
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Expandable Search Bar Card
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TextField("Search food...", text: $searchText)
                        .submitLabel(.search)
                        .onSubmit { vm.currentProduct = nil }
                        .onChange(of: searchText) { oldText, newText in
                            vm.currentProduct = nil
                            scannedCode = nil
                            vm.errorMessage = nil
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
                            scannedCode = code
                            vm.currentProduct = nil
                            vm.errorMessage = nil
                            Task { await vm.fetchProduct(barcode: code) }
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

            // Fetched Product Input
            if let product = vm.currentProduct,
               !vm.allFoods.contains(where: { $0.barcode == product.barcode }) {
                FoodRowView(food: product, viewModel: vm, mealType: mealType)
                    .padding(.horizontal, 23)
                    .padding(.top, 13)
            }

            // API Lookup Error
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.horizontal, 23)
                    .padding(.vertical, 8)
            }

            // Food List
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredFoods, id: \.id) { item in
                        FoodRowView(food: item, viewModel: vm, mealType: mealType)
                            .background(colorScheme == .dark ? Color.black : Color.white)
                    }
                }
                .padding(.horizontal, 23)
                .padding(.top, isShowingScanner ? 13 : 13)
            }
            .frame(maxHeight: 550)

            Spacer()
        }
    }
}

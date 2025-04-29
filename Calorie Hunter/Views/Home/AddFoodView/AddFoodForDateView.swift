import SwiftUI

/// Presents the shared search/list UI for a specific date.
struct AddFoodForDateView: View {
    @ObservedObject var viewModel: DateFoodViewModel
    @Environment(\.dismiss) private var dismiss
    let preselectedMealType: String

    @State private var searchText = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String? = nil

    var body: some View {
        NavigationView {
            FoodSearchListView(
                vm: viewModel,
                searchText: $searchText,
                isShowingScanner: $isShowingScanner,
                scannedCode: $scannedCode,
                mealType: preselectedMealType
            )
        }
        .navigationTitle(
            "Add Food for " +
            DateFormatter.localizedString(
                from: viewModel.date,
                dateStyle: .medium,
                timeStyle: .none
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var isManualEntryPresented: Bool = false  // State to control sheet presentation
    
    private var combinedFoods: [FoodItem] {
        PredefinedFoods.foods + PredefinedUserFoods.shared.foods
    }
    
    private var filteredFoods: [FoodItem] {
        searchText.isEmpty ? combinedFoods : combinedFoods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search food...", text: $searchText)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.black))
                            .shadow(color: Color.cyan.opacity(0.25), radius: 8)
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 25)
                    .padding(.bottom, 9)
                
                // List of foods; each row is handled by FoodRowView.
                if !filteredFoods.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredFoods, id: \.id) { food in
                                FoodRowView(food: food, viewModel: viewModel)
                            }
                        }
                    }
                    .frame(maxHeight: 460)
                }
                
                Spacer()
                
                // Button to open manual entry using SwiftUI's native .sheet modifier
                ExpandingButton(title: "Manual Entry") {
                    isManualEntryPresented = true
                }
                .padding(.horizontal, 30)
                
            }
            .navigationTitle("Add Food")
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isManualEntryPresented) {
                ManualEntryView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    AddFoodView(viewModel: FoodViewModel())
}

import Foundation

/// A minimal view‐model interface for food‐adding UIs.
@MainActor
protocol FoodAddingViewModel: ObservableObject {
    /// The product fetched from the API or barcode scanner.
    var currentProduct: FoodItem? { get set }
    /// An error message for lookup failures.
    var errorMessage: String? { get set }

    /// The full catalog or history of foods available for searching.
    var allFoods: [FoodItem] { get }
    /// Look up a single food by its barcode.
    func findFood(byBarcode code: String) -> FoodItem?

    /// Fetch a new product via API lookup (e.g. OpenFoodFacts).
    func fetchProduct(barcode: String) async
    /// Log a consumption event (grams & meal type) into the diary.
    func logConsumption(of food: FoodItem, grams: Double, mealType: String)
}

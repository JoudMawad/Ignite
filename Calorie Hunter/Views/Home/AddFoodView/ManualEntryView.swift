import SwiftUI

struct ManualEntryView: View {
    // MARK: - Dependencies
    @ObservedObject var viewModel: FoodViewModel
    @Environment(\.colorScheme) var colorScheme
    var onSuccessfulDismiss: () -> Void

    // MARK: - State Properties
    @State private var name: String = ""
    @State private var grams: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var barcodeCode: String? = nil
    
    @State private var showLabelScanner = false
    @State private var ocrCalories: Int?
    @State private var ocrProtein:  Double?
    @State private var ocrCarbs:    Double?
    @State private var ocrFat:      Double?

    @State private var errorMessages: [String] = []
    @State private var successMessage: String? = nil
    @State private var isShowingScanner: Bool = false

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    init(
            viewModel: FoodViewModel,
            scannedBarcode: String? = nil,
            onSuccessfulDismiss: @escaping () -> Void
        ) {
            self.viewModel = viewModel
            self.onSuccessfulDismiss = onSuccessfulDismiss
            _barcodeCode = State(initialValue: scannedBarcode)
        }

    // MARK: - Helpers
    private func sanitizeDoubleInput(_ input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: "."))
    }
    private var isFormValid: Bool {
        let fields = [name, grams, calories, protein, carbs, fat]
        guard fields.allSatisfy({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }) else { return false }
        return sanitizeDoubleInput(grams) != nil &&
               sanitizeDoubleInput(calories) != nil &&
               sanitizeDoubleInput(protein) != nil &&
               sanitizeDoubleInput(carbs) != nil &&
               sanitizeDoubleInput(fat) != nil
    }

    // MARK: - Body
    var body: some View {
        VStack {
            CardView {
                VStack(alignment: .leading, spacing: 5) {
                    // Title
                    Text("Food Information")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .black : .white)

                    // Barcode Section (above name field)
                    HStack(spacing: 12) {
                        Button(action: { isShowingScanner = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "barcode.viewfinder")
                                Text("Add Barcode")
                            }
                            .font(.subheadline)
                            .padding(10)
                        }
                        .accessibility(label: Text("Add or scan barcode"))

                        Text(barcodeCode ?? "No barcode scanned")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()
                        
                        Button("Scan Nutrition Label") { showLabelScanner = true }
                            .sheet(isPresented: $showLabelScanner) {
                                NutritionCaptureView { facts in
                                    if let v = facts.calories { calories = "\(v)" }
                                    if let v = facts.protein  { protein  = "\(v)" }
                                    if let v = facts.carbs    { carbs    = "\(v)" }
                                    if let v = facts.fat      { fat      = "\(v)" }
                                }
                            }

                    }

                    // Feedback Messages
                    if !errorMessages.isEmpty {
                        VStack(spacing: 5) {
                            ForEach(errorMessages, id: \.self) { msg in
                                Text(msg)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    if let ok = successMessage {
                        Text(ok)
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }

                    // Input Fields
                    InputField(text: $name, placeholder: "Food Name")
                    InputField(text: $grams, placeholder: "Grams Consumed", keyboardType: .decimalPad)
                    InputField(text: $calories, placeholder: "Calories", keyboardType: .decimalPad)
                    InputField(text: $protein, placeholder: "Protein (g)", keyboardType: .decimalPad)
                    InputField(text: $carbs, placeholder: "Carbs (g)", keyboardType: .decimalPad)
                    InputField(text: $fat, placeholder: "Fat (g)", keyboardType: .decimalPad)

                    // Add to Storage Button (centered)
                    HStack {
                        Spacer()
                        ExpandingButton2(title: "Add to Storage") {
                            handleAddToStorage()
                        }
                        Spacer()
                    }
                    .padding(.vertical, -40)
                }
                .padding(1.5)
            }
            .onTapGesture { hideKeyboard() }
        }
        // Scanner Sheet
        .sheet(isPresented: $isShowingScanner) {
            BarcodeScannerView { code in
                barcodeCode = code
                isShowingScanner = false
            }
        }
    }

    // MARK: - Actions
    private func handleAddToStorage() {
        errorMessages = []
        // 1) Basic form completeness
        guard isFormValid else {
            errorMessages.append("All fields must be filled correctly.")
            return
        }
        // 2) Enforce exactly 100g
        if let gramsValue = sanitizeDoubleInput(grams) {
            if gramsValue != 100 {
                errorMessages.append("Grams must be exactly 100.")
                return
            }
        } else {
            errorMessages.append("Grams must be exactly 100.")
            return
        }
        // 3) Duplicate name check
        let allFoods = PredefinedFoods.foods + PreDefinedUserFoods.shared.foods
        if allFoods.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            errorMessages.append("A food with this name already exists.")
            return
        }
        // 4) If we reach here, add to storage
        let newFood = FoodItem(
            name: name,
            calories: Int(calories) ?? 0,
            protein: sanitizeDoubleInput(protein) ?? 0,
            carbs: sanitizeDoubleInput(carbs) ?? 0,
            fat: sanitizeDoubleInput(fat) ?? 0,
            grams: 100,
            mealType: mealType,
            barcode: barcodeCode
        )
        viewModel.addUserPredefinedFood(food: newFood)
        successMessage = "Added to storage!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onSuccessfulDismiss()
        }
    }
}

// MARK: - Custom Card View
struct CardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 55, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 55, style: .continuous)
                    .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 2)
            )
    }
}

// MARK: - Reusable Input Field View
struct InputField: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text)
            .keyboardType(keyboardType)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
            .placeholder(placeholder, when: text.isEmpty, placeholderColor: .gray)
            .accessibilityLabel(placeholder)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .padding(.vertical, -5)
    }
}

// MARK: - Placeholder Modifier
struct PlaceholderStyle: ViewModifier {
    var show: Bool
    var placeholder: String
    var placeholderColor: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if show {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 15)
            }
            content
                .foregroundColor(.primary)
                .padding(10)
        }
    }
}

extension View {
    func placeholder(_ text: String, when shouldShow: Bool, placeholderColor: Color = .gray) -> some View {
        self.modifier(PlaceholderStyle(show: shouldShow, placeholder: text, placeholderColor: placeholderColor))
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - Preview
#Preview {
    ManualEntryView(viewModel: FoodViewModel(), onSuccessfulDismiss: {})
}

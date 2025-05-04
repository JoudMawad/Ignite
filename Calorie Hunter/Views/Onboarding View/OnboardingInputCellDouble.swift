import SwiftUI

/// A reusable input cell designed for onboarding screens that accepts a Double value.
/// The cell displays an optional system image, a title, and a centered text field with a placeholder.
struct OnboardingInputCellDouble: View {
    // MARK: - Input Properties
    
    var title: String
    var placeholder: String = ""
    var systemImageName: String? = nil
    @Binding var value: Double

    // MARK: - Environment & Focus
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

    // MARK: - Formatter
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }

    // MARK: - Local Input State
    
    /// Hold the text while the user types; only commit back into `value` when they finish.
    @State private var text: String = ""

    private func commit() {
        // Parse the text and update the bound Double
        if let number = numberFormatter.number(from: text) {
            value = number.doubleValue
        }
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)

            ZStack {
                if !isFocused && text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 18))
                }
                TextField("", text: $text, onEditingChanged: { began in
                    if !began {
                        commit()
                    }
                })
                .submitLabel(.done)
                .onSubmit { commit() }
                .tint(.blue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .focused($isFocused)
            }
            .frame(height: 30)
            .onAppear {
                // Initialize the text field from the bound Double value
                text = numberFormatter.string(from: NSNumber(value: value)) ?? ""
            }
            .onChange(of: value) {
                // Update text when the bound value changes externally
                text = numberFormatter.string(from: NSNumber(value: value)) ?? ""
            }
        }
        .frame(width: 200, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onTapGesture { isFocused = true }
    }
}

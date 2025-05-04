import SwiftUI

/// A reusable input cell designed for onboarding screens that accepts an integer value.
/// The cell displays an optional system image, a title, and a centered text field with a placeholder.
struct OnboardingInputCellInt: View {
    // MARK: - Input Properties
    
    /// The title text displayed above the input field.
    var title: String
    
    /// The placeholder text shown when the field is empty and unfocused.
    var placeholder: String = ""
    
    /// An optional system image name to display above the title.
    var systemImageName: String? = nil
    
    /// A binding to the integer value being input by the user.
    @Binding var value: Int
    
    // Local text state for editing
    @State private var text: String = ""
    
    // MARK: - Environment & Focus State
    
    /// Provides the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    /// Tracks whether the text field is currently focused.
    @FocusState private var isFocused: Bool

    // MARK: - Formatter
    
    /// A NumberFormatter configured for integer input without grouping separators.
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        // Ensures no fractional digits are shown.
        formatter.maximumFractionDigits = 0
        // Disable grouping separators (e.g., no commas in thousands)
        formatter.usesGroupingSeparator = false
        return formatter
    }
    
    /// Parse the current text and update the bound integer value.
    private func commit() {
        if let number = numberFormatter.number(from: text)?.intValue {
            value = number
        }
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            // Optionally display a system image if provided.
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }
            
            // Display the title above the text field.
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            ZStack {
                // Show the placeholder text only when the field is not focused and the value is zero.
                if !isFocused && value == 0 {
                    Text(placeholder)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: 18, weight: .regular))
                }
                // The TextField binds directly to the integer value using the configured formatter.
                TextField("", text: $text, onEditingChanged: { began in
                    if !began {
                        commit()
                    }
                })
                .submitLabel(.done)
                .onSubmit { commit() }
                .tint(Color.blue) // Sets the accent and cursor color.
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .focused($isFocused) // Connects the focus state.
            }
            .onAppear {
                // Initialize the text field from the bound Int value
                text = numberFormatter.string(from: NSNumber(value: value)) ?? ""
            }
            .onChange(of: value) {
                // Keep text in sync if value changes externally
                text = numberFormatter.string(from: NSNumber(value: value)) ?? ""
            }
            .frame(height: 30) // Fixes the height of the input container.
        }
        .frame(width: 200, height: 100) // Defines the overall size of the cell.
        .background(
            // Uses a rounded rectangle background that adapts to the color scheme with a subtle shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        // When the user taps anywhere on the cell, set focus to the text field.
        .onTapGesture {
            isFocused = true
        }
    }
}

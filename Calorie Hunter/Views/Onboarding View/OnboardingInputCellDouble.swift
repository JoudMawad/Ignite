import SwiftUI

/// A reusable input cell designed for onboarding screens that accepts a Double value.
/// The cell displays an optional system image, a title, and a centered text field with a placeholder.
struct OnboardingInputCellDouble: View {
    // MARK: - Input Properties
    
    /// The title text displayed above the input field.
    var title: String
    
    /// The placeholder text shown when the field is empty and unfocused.
    var placeholder: String = ""
    
    /// An optional system image name to display above the title.
    var systemImageName: String? = nil
    
    /// A binding to the Double value being input by the user.
    @Binding var value: Double
    
    // MARK: - Environment & Focus State
    
    /// Accesses the current color scheme (light or dark) for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    /// Manages the focus state of the text field.
    @FocusState private var isFocused: Bool

    // MARK: - Formatter
    
    /// A NumberFormatter configured to display decimals using the current locale.
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        // Maximum fraction digits is set to 10 to support high precision.
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        return formatter
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            // Optionally display a system image if provided.
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    // Adjust the image color based on the color scheme.
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }
            
            // Display the title above the text field.
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            ZStack {
                // Display the placeholder only if the field is not focused and the value is 0.
                if !isFocused && (value == 0.0) {
                    Text(placeholder)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: 18, weight: .regular))
                }
                // The TextField binds to the Double value with a custom formatter.
                TextField("", value: $value, formatter: numberFormatter)
                    .tint(Color.blue) // Cursor and accent color.
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .focused($isFocused) // Track focus state.
            }
            .frame(height: 30) // Set a fixed height for the input field container.
        }
        .frame(width: 200, height: 100) // Set a fixed overall size for the cell.
        .background(
            // A rounded rectangle background that adapts its color to the current color scheme.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        // Tapping anywhere on the cell activates the text field.
        .onTapGesture {
            isFocused = true
        }
    }
}

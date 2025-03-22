import SwiftUI

struct OnboardingInputCellInt: View {
    var title: String
    var placeholder: String = ""
    var systemImageName: String? = nil
    @Binding var value: Int
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

    // Configure a NumberFormatter for integers.
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        // Ensure no fractional digits are allowed.
        formatter.maximumFractionDigits = 0
        return formatter
    }

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
                // Show placeholder when the field isn't focused and value is zero.
                if !isFocused && value == 0 {
                    Text(placeholder)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: 18, weight: .regular))
                }
                // Bind directly to the integer value using a formatter.
                TextField("", value: $value, formatter: numberFormatter)
                    .tint(Color.blue)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .focused($isFocused)
            }
            .frame(height: 30)
        }
        .frame(width: 200, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

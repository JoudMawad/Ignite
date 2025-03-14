import SwiftUI

struct OnboardingInputCellDouble: View {
    var title: String
    var placeholder: String = ""
    var systemImageName: String? = nil
    @Binding var value: Double
    @State private var textValue: String = ""
    @Environment(\.colorScheme) var colorScheme

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
                if textValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 18, weight: .regular))
                }
                TextField("", text: Binding(
                    get: {
                        if textValue.isEmpty && value == 0.0 {
                            return ""
                        }
                        return textValue
                    },
                    set: { newValue in
                        // Replace any commas with dots.
                        let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                        textValue = newValue
                        if let doubleValue = Double(normalized) {
                            value = doubleValue
                        } else {
                            value = 0.0
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .frame(height: 30)
        }
        .frame(width: 200, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

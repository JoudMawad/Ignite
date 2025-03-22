import SwiftUI

struct OnboardingInputCellString: View {
    var title: String
    var placeholder: String = ""
    var systemImageName: String? = nil
    @Binding var value: String
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

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
            // Bind the TextField directly to the string value.
            TextField(placeholder, text: $value)
                .tint(Color.blue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .focused($isFocused)
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

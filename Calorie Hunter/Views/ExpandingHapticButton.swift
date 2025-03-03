import SwiftUI

struct ExpandingButton: View {
    var title: String
    var action: () -> Void // ✅ Custom action when tapped
    
    @Environment(\.colorScheme) var colorScheme // Detect Light/Dark Mode
    @State private var isPressed = false // Track button press state
    
    var body: some View {
        Button(action: {
            giveHapticFeedback() // ✅ Haptic feedback on tap
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Reset scale after animation
                isPressed = false
            }
            action() // ✅ Execute the passed action
        }) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? Color.white : Color.black) // ✅ Dynamic Background Color
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white) // ✅ Dynamic Text Color
                .cornerRadius(10)
                .scaleEffect(isPressed ? 1.1 : 1.0) // ✅ Expands slightly when tapped
        }
        .padding()
    }

    // ✅ Function to Provide Haptic Feedback
    func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    ExpandingButton(title: "Tap Me") {
        print("Button Pressed")
    }
}



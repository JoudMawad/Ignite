import SwiftUI

// ExpandingButton2 is a custom button that gives haptic feedback,
// animates an expanding effect, and cycles its gradient when tapped.
struct ExpandingButton2: View {
    // The text to display on the button.
    var title: String
    // A closure that executes a custom action when the button is tapped.
    var action: () -> Void
    
    // Detects whether the app is in light or dark mode.
    @Environment(\.colorScheme) var colorScheme
    // State variable to track whether the button is pressed.
    @State private var isPressed = false
    // State variables for animating gradient start and end points.
    @State private var gradientStart: UnitPoint = .leading
    @State private var gradientEnd: UnitPoint = .trailing

    var body: some View {
        Button(action: {
            // Provide haptic feedback when the button is tapped.
            giveHapticFeedback()
            
            // Animate the button expanding using a spring animation.
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            
            // Animate the gradient's direction to create a dynamic effect.
            withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                gradientStart = .trailing
                gradientEnd = .leading
            }
            
            // Reset the button's pressed state after 1.2 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPressed = false
            }
            
            // Execute the custom action passed to the button.
            action()
        }) {
            ZStack {
                // The button's label.
                Text(title)
                    .font(.headline)
                    .padding()
                    // Background color changes based on the current color scheme.
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    // Text color is inverted relative to the background.
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .cornerRadius(12)
                    // Slightly enlarge the button when pressed.
                    .scaleEffect(isPressed ? 1.05 : 1.0)
                    // Animate the scale change for a smooth effect.
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            // Fix the button's size regardless of the text content.
            .frame(width: 200, height: 100)
        }
        .padding()
    }

    /// Provides medium impact haptic feedback when the button is tapped.
    func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    ExpandingButton2(title: "Tap Me") {
        print("Button Pressed")
    }
}

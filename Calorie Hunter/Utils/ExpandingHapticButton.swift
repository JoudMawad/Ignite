import SwiftUI

// ExpandingButton is a custom button view that animates when tapped,
// provides haptic feedback, and adapts its colors to the current Light/Dark mode.
struct ExpandingButton: View {
    // The text displayed on the button.
    var title: String
    // A closure that executes a custom action when the button is tapped.
    var action: () -> Void // Custom action when tapped
    
    // Access the current color scheme (light or dark) from the environment.
    @Environment(\.colorScheme) var colorScheme // Detect Light/Dark Mode
    // State variable that tracks whether the button is pressed.
    @State private var isPressed = false // Track button press state
    // State variables for animating the gradient's start and end points.
    @State private var gradientStart: UnitPoint = .leading
    @State private var gradientEnd: UnitPoint = .trailing

    var body: some View {
        Button(action: {
            // Provide haptic feedback when the button is tapped.
            giveHapticFeedback() // Haptic feedback on tap
            
            // Animate the button expanding slightly when pressed using a spring animation.
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }

            // Start animating the gradient colors (this will loop indefinitely).
            // Even though we set up the gradient animation, it isn't applied to any view in the current code.
            // You might want to use it as a foreground or background style in your view if desired.
            withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                gradientStart = .trailing
                gradientEnd = .leading
            }

            // Stop the button expansion animation after 1.2 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPressed = false
            }
            
            // Execute the custom action passed to the button.
            action() // Execute the passed action
        }) {
            ZStack {
                // The button's content: a text label.
                Text(title)
                    .font(.headline)
                    .frame(width: 280, height: 30)
                    .padding()
                    // Set the background color dynamically based on the color scheme.
                    .background(colorScheme == .dark ? Color.white : Color.black) // Dynamic Background Color
                    // Set the text color dynamically based on the color scheme.
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white) // Dynamic Text Color
                    .cornerRadius(12)
                    // Slightly enlarge the button when pressed.
                    .scaleEffect(isPressed ? 1.05 : 1.0) // Expands slightly when tapped
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
        }
        .padding()
    }

    // Function to provide haptic feedback when the button is pressed.
    func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    // A preview of the ExpandingButton with a sample action that prints a message.
    ExpandingButton(title: "Tap Me") {
        print("Button Pressed")
    }
}

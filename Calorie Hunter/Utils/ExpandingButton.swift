import SwiftUI

struct ExpandingButton2: View {
    var title: String
    var action: () -> Void // ✅ Custom action when tapped
    
    @Environment(\.colorScheme) var colorScheme // Detect Light/Dark Mode
    @State private var isPressed = false // Track button press state
    @State private var gradientStart: UnitPoint = .leading
    @State private var gradientEnd: UnitPoint = .trailing
    

    var body: some View {
        Button(action: {
            giveHapticFeedback() // ✅ Haptic feedback on tap
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }

            // Start animating gradient colors
            withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                gradientStart = .trailing
                gradientEnd = .leading
            }

            // Stop animation after 1.2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPressed = false
            }
            
            action() // ✅ Execute the passed action
        }) {
            ZStack {
                
                // Button content
                Text(title)
                    .font(.headline)
                    
                    .padding()
                    .background(colorScheme == .dark ? Color.white : Color.black) // ✅ Dynamic Background Color
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white) // ✅ Dynamic Text Color
                    .cornerRadius(12)
                    .scaleEffect(isPressed ? 1.05 : 1.0) // ✅ Expands slightly when tapped
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
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

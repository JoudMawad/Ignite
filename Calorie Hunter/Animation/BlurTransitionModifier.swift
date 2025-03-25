import SwiftUI

// MARK: - Custom Transition for Alerts

// This view modifier applies a blur effect based on whether it's active or not.
struct BlurTransitionModifier: ViewModifier {
    // Determines if the blur effect should be applied.
    let active: Bool
    
    // The body method applies the blur to the given content.
    func body(content: Content) -> some View {
        // When active is true, the content is blurred with a radius of 30; otherwise, no blur.
        content.blur(radius: active ? 30 : 0)
    }
}

extension AnyTransition {
    // A custom transition that combines a blur effect and a scaling effect.
    static var blurScale: AnyTransition {
        AnyTransition.modifier(
            active: BlurTransitionModifier(active: true),   // When the transition is active, apply the blur.
            identity: BlurTransitionModifier(active: false)   // When inactive, display normally.
        ).combined(with: .scale)  // Combine the blur effect with a scaling animation.
    }
}

// MARK: - Reusable Custom Alert Overlay

// This view represents a reusable alert overlay that displays a title, message, and allows dismissal.
struct CustomAlertOverlay: View {
    // Title of the alert.
    let title: String
    // Message to be displayed in the alert.
    let message: String
    // A closure that gets called when the alert is dismissed.
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // A semi-transparent black background to dim the content behind the alert.
            Color.black.opacity(0.4)
                .ignoresSafeArea()  // Extend the color over the entire screen.
                // When the background is tapped, dismiss the alert with an animation.
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onDismiss()
                    }
                }
            // The custom alert view that displays the title and message.
            CustomAlert(
                title: title,
                message: message,
                onDismiss: {
                    // Dismiss the alert with an animation when a dismiss action occurs.
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onDismiss()
                    }
                }
            )
            // Apply the custom transition that combines blur and scale effects.
            .transition(.blurScale)
            // Ensure the alert appears on top of the dimmed background.
            .zIndex(1)
        }
    }
}

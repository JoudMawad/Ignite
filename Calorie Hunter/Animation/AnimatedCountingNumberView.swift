import SwiftUI

// This view displays a number that can animate from one value to another.
struct AnimatedCountingNumberView: View {
    // The target value to be shown (and animated to) when the view appears or changes.
    let newValue: Double
    
    // A local state that holds the value currently displayed by the view.
    // This value changes over time to animate the counting effect.
    @State private var displayedValue: Double = 0

    // A static flag to ensure that the counting animation only plays once per app session.
    // Subsequent appearances of the view will update immediately without the animation.
    private static var hasAnimatedCountingNumber = false

    var body: some View {
        // The custom view that takes in a number and renders it, potentially in a formatted style.
        CountingNumberText(number: displayedValue)
            // When the view first appears...
            .onAppear {
                // Check if the counting animation has already run in this session.
                if Self.hasAnimatedCountingNumber {
                    // If it has, we simply update the value instantly without animation.
                    displayedValue = newValue
                } else {
                    // For the first appearance, we start at 0...
                    displayedValue = 0
                    // ...and then animate the change to the new value over half a second.
                    withAnimation(.easeInOut(duration: 0.5)) {
                        displayedValue = newValue
                    }
                    // Mark that the animation has now played so we don't run it again in this session.
                    Self.hasAnimatedCountingNumber = true
                }
            }
            // When the new value changes (after the view is already on screen)...
            .onChange(of: newValue) { oldValue, newValue in
                // ...animate the transition to the new value using the same timing as before.
                withAnimation(.easeInOut(duration: 0.5)) {
                    displayedValue = newValue
                }
            }
    }
}

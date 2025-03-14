import SwiftUI

struct AnimatedCountingNumberView: View {
    /// The new value that should be animated into view.
    let newValue: Double
    /// Local state that drives the displayed value.
    @State private var displayedValue: Double = 0

    /// A static flag that tracks whether the animation has already played during this app launch.
    private static var hasAnimatedCountingNumber = false

    var body: some View {
        CountingNumberText(number: displayedValue)
            .onAppear {
                if Self.hasAnimatedCountingNumber {
                    // If already animated, update immediately without animation.
                    displayedValue = newValue
                } else {
                    // Animate from 0 to the new value on first appearance in this app session.
                    displayedValue = 0
                    withAnimation(.easeInOut(duration: 0.5)) {
                        displayedValue = newValue
                    }
                    Self.hasAnimatedCountingNumber = true
                }
            }
            .onChange(of: newValue) { oldValue, newValue in
                // Animate when a truly new value arrives.
                withAnimation(.easeInOut(duration: 0.5)) {
                    displayedValue = newValue
                }
            }
    }
}

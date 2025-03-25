import SwiftUI

// A custom view that simulates a typewriter effect by revealing text one character at a time.
struct TypewriterText: View {
    // The complete text to be displayed.
    let fullText: String
    // The time interval between each character's appearance.
    let interval: TimeInterval
    // An optional closure called when the full text has been displayed.
    var onCompletion: (() -> Void)? = nil

    // Local state to keep track of the currently displayed text.
    @State private var currentText: String = ""
    // A progress value from 0.0 to 1.0 tracking the animation state.
    @State private var progress: CGFloat = 0.0
    
    // Access the current color scheme (light or dark) to adjust text color accordingly.
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        // 1) Calculate visual style transformations based on the current progress.
        // Adjust opacity using an easing function for a smoother fade-in effect.
        let opacity = UnitCurve.easeIn.value(at: 1.4 * progress)
        // Apply a decreasing blur as more text is revealed.
        let blurRadius = (1.0 - progress) * 2.0
        // Slide the text upward gradually.
        let translationY = (1.0 - progress) * 10.0

        return Text(currentText)
            // Use a large, bold, rounded font style for the text.
            .font(.system(size: 35, weight: .bold, design: .rounded))
            // Adjust text color based on the environment's color scheme.
            .foregroundColor(colorScheme == .dark ? .white : .black)
            // Center-align the text across multiple lines.
            .multilineTextAlignment(.center)
            // Add horizontal padding to keep text from touching screen edges.
            .padding(.horizontal, 40)
            // 2) Apply visual transformations to create a smooth appearance effect.
            .opacity(opacity)
            .blur(radius: blurRadius)
            .offset(y: translationY)
            // 3) Implement the typewriter animation logic.
            .onAppear {
                // Start with an empty string.
                currentText = ""
                var charIndex = 0

                // Schedule a timer that fires at the specified interval to add one character at a time.
                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                    // Once we've appended all characters, stop the timer.
                    guard charIndex < fullText.count else {
                        timer.invalidate()
                        // Call the completion closure after a brief delay if provided.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onCompletion?()
                        }
                        return
                    }
                    
                    // Get the index for the next character in the fullText.
                    let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                    // Append the next character to the currentText.
                    currentText.append(fullText[index])
                    charIndex += 1

                    // Calculate new progress based on the number of characters displayed.
                    let newProgress = CGFloat(charIndex) / CGFloat(fullText.count)
                    
                    // Animate the progress change to update opacity, blur, and offset smoothly.
                    withAnimation(.linear(duration: 0.15)) {
                        progress = newProgress
                    }
                }
            }
    }
}

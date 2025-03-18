import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let interval: TimeInterval
    var onCompletion: (() -> Void)? = nil

    @State private var currentText: String = ""
    @State private var progress: CGFloat = 0.0  // Tracks how far along we are (0.0 to 1.0)
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        // 1) Calculate style values from progress
        let opacity = UnitCurve.easeIn.value(at: 1.4 * progress)
        let blurRadius = (1.0 - progress) * 2.0
        let translationY = (1.0 - progress) * 10.0

        return Text(currentText)
            .font(.system(size: 35, weight: .bold, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            // 2) Apply style transformations
            .opacity(opacity)
            .blur(radius: blurRadius)
            .offset(y: translationY)
            // 3) Typewriter logic
            .onAppear {
                currentText = ""
                var charIndex = 0

                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                    guard charIndex < fullText.count else {
                        timer.invalidate()
                        // Call onCompletion after a short delay, if desired
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onCompletion?()
                        }
                        return
                    }
                    
                    // Append the next character
                    let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                    currentText.append(fullText[index])
                    charIndex += 1

                    // Update our progress (0.0 -> 1.0) as characters appear
                    let newProgress = CGFloat(charIndex) / CGFloat(fullText.count)
                    
                    // Animate the style change for each new character
                    withAnimation(.linear(duration: 0.15)) {
                        progress = newProgress
                    }
                }
            }
    }
}

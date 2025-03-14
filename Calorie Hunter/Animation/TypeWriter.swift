import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let interval: TimeInterval
    var onCompletion: (() -> Void)? = nil

    @State private var currentText: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(currentText)
            .font(.system(size: 35, weight: .bold, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .onAppear {
                currentText = ""
                var charIndex = 0
                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                    if charIndex < fullText.count {
                        let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                        currentText.append(fullText[index])
                        charIndex += 1
                    } else {
                        timer.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onCompletion?()
                        }
                    }
                }
            }
    }
}

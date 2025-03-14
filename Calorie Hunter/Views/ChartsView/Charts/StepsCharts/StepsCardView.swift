import SwiftUI

struct StepsCardView: View {
    @ObservedObject var stepsViewModel: StepsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var animatedSteps: Double = 0

    /// A static flag that tracks whether the steps animation has already played this app session.
    private static var hasAnimatedSteps = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                Text("Steps")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            CountingNumberText(number: animatedSteps)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            Spacer()
        }
        .padding()
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            if Self.hasAnimatedSteps {
                // If already animated once, set the value immediately.
                animatedSteps = Double(stepsViewModel.currentSteps)
            } else {
                // Animate from 0 to the current value on the first appearance.
                animatedSteps = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedSteps = Double(stepsViewModel.currentSteps)
                }
                Self.hasAnimatedSteps = true
            }
        }
        .onReceive(stepsViewModel.$currentSteps) { newValue in
            // Animate changes whenever a new value arrives.
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedSteps = Double(newValue)
            }
        }
    }
}

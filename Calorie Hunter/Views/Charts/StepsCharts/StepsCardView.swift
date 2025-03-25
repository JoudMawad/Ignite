import SwiftUI

struct StepsCardView: View {
    // Observed user profile for accessing user-specific settings.
    @ObservedObject var viewModel: UserProfileViewModel
    // Observed steps view model providing current steps data.
    @ObservedObject var stepsViewModel: StepsViewModel
    // Adapts UI styling based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    // Animated value for smooth transitions in the displayed step count.
    @State private var animatedSteps: Double = 0
    
    // Closure to trigger additional actions when steps change (currently unused).
    var onStepsChange: () -> Void = {}
    
    /// Static flag to ensure the initial animation only plays once per app session.
    private static var hasAnimatedSteps = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Walk icon indicating the steps metric.
                Image(systemName: "figure.walk")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                // Title label for the card.
                Text("Steps")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Animated number text displaying the current step count.
            CountingNumberText(number: animatedSteps)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            // Progress view showing visual feedback of steps progress.
            StepsProgressView(viewModel: viewModel,
                              stepsViewModel: stepsViewModel,
                              onStepsChange: onStepsChange)
        }
        .padding(.horizontal)
        .frame(width: 120, height: 120)
        .background(
            // Rounded rectangle background with adaptive color and shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            // Check if the initial animation has already played.
            if Self.hasAnimatedSteps {
                // Set the animated steps immediately if already animated.
                animatedSteps = Double(stepsViewModel.currentSteps)
            } else {
                // Animate from 0 to the current steps value on first appearance.
                animatedSteps = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedSteps = Double(stepsViewModel.currentSteps)
                }
                Self.hasAnimatedSteps = true
            }
        }
        .onReceive(stepsViewModel.$currentSteps) { newValue in
            // Animate any subsequent changes in step count.
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedSteps = Double(newValue)
            }
        }
    }
}

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
    /// Animated value for smooth transitions in the displayed distance.
    @State private var animatedDistance: Double = 0
    
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
                    .foregroundColor(.green)
                
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
            
            // Distance display
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                // Compute and display distance in km with one decimal
                let rawKm = animatedDistance / 1000
                let roundedKm = (rawKm * 10).rounded() / 10
                Text(String(format: "%.1f km", roundedKm))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
        .padding(.horizontal)
        .frame(width: 120, height: 140)
        .background(
            // Rounded rectangle background with adaptive color and shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            if Self.hasAnimatedSteps {
                animatedSteps = Double(stepsViewModel.currentSteps)
                animatedDistance = stepsViewModel.currentDistance
            } else {
                animatedSteps = 0
                animatedDistance = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedSteps = Double(stepsViewModel.currentSteps)
                    animatedDistance = stepsViewModel.currentDistance
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
        // Animate on distance change
        .onReceive(stepsViewModel.$currentDistance) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedDistance = newValue
            }
        }
    }
}

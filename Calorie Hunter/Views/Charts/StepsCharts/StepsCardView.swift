import SwiftUI

struct StepsCardView: View {
    // Observed user profile for accessing user-specific settings.
    @ObservedObject var goalsViewModel: GoalsViewModel
    // Observed steps view model providing current steps data.
    @ObservedObject var stepsViewModel: StepsViewModel
    // Adapts UI styling based on the current light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    // Closure to trigger additional actions when steps change (currently unused).
    var onStepsChange: () -> Void = {}
    
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
            
            // Step count (mirrors Health app Today)
            CountingNumberText(number: Double(stepsViewModel.currentSteps))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .animation(.easeInOut(duration: 0.5), value: stepsViewModel.currentSteps)
            
            // Distance display
            HStack {
                // Compute and display distance in km with one decimal
                let rawKm = stepsViewModel.currentDistance / 1000
                let roundedKm = (rawKm * 10).rounded() / 10
                Text(String(format: "%.1f km", roundedKm))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .animation(.easeInOut(duration: 0.5), value: stepsViewModel.currentDistance)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, -5)
            
            // Progress view showing visual feedback of steps progress.
            StepsProgressView(goalsviewModel: goalsViewModel,
                              stepsViewModel: stepsViewModel,
                              onStepsChange: onStepsChange)
            
            
        }
        .padding(.horizontal)
        .frame(width: 120, height: 140)
        .background(
            // Rounded rectangle background with adaptive color and shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
    }
}

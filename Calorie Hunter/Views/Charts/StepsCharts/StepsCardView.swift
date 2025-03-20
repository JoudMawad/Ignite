import SwiftUI

struct StepsCardView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var stepsViewModel: StepsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var animatedSteps: Double = 0
    
    var onStepsChange: () -> Void = {}
    
    /// Static flag to track whether the steps animation has already played.
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
            CountingNumberText(number: animatedSteps)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            StepsProgressView(viewModel: viewModel,
                              stepsViewModel: stepsViewModel,
                              onStepsChange: onStepsChange)
        }
        .padding(.horizontal)
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            if Self.hasAnimatedSteps {
                animatedSteps = Double(stepsViewModel.currentSteps)
            } else {
                animatedSteps = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedSteps = Double(stepsViewModel.currentSteps)
                }
                Self.hasAnimatedSteps = true
            }
        }
        .onReceive(stepsViewModel.$currentSteps) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedSteps = Double(newValue)
            }
        }
    }
}

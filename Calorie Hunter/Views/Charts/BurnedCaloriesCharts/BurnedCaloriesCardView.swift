import SwiftUI

struct BurnedCaloriesCardView: View {
    // View model tracking burned calories logic.
    @StateObject var burnedCaloriesviewModel = BurnedCaloriesViewModel()
    // User profile data needed for contextual display.
    @ObservedObject var viewModel: UserProfileViewModel
    // Animated value used to smoothly update the calories display.
    @State private var animatedCalories: Double = 0
    // Adjusts styling based on the current UI color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// A static flag ensuring the launch animation is only executed once per session.
    private static var hasAnimatedBurnedCalories = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title section with icon and label.
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                Text("Burned Calories")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Animated number display for burned calories.
            CountingNumberText(number: animatedCalories)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            // Progress view reflecting the burned calories update.
            BurnedCaloriesProgressView(
                viewModel: viewModel,
                burnedCaloriesViewModel: burnedCaloriesviewModel,
                onBurnedCaloriesChange: { }
            )
        }
        .padding(.horizontal)
        .frame(width: 120, height: 120)
        .background(
            // Background with rounded corners and a subtle shadow for depth.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            // Check if launch animation has been played during this app session.
            if Self.hasAnimatedBurnedCalories {
                // Directly set to the current value if already animated.
                animatedCalories = burnedCaloriesviewModel.currentBurnedCalories
            } else {
                // Start from zero and animate to the current burned calories value.
                animatedCalories = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedCalories = burnedCaloriesviewModel.currentBurnedCalories
                }
                Self.hasAnimatedBurnedCalories = true
            }
        }
        .onReceive(burnedCaloriesviewModel.$currentBurnedCalories) { newValue in
            // Animate changes in burned calories when updated.
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedCalories = newValue
            }
        }
    }
}

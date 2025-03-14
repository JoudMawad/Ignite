import SwiftUI

struct BurnedCaloriesCardView: View {
    @StateObject var viewModel = BurnedCaloriesViewModel()
    @State private var animatedCalories: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    // Static flag to ensure the launch animation only plays once per app session.
    private static var hasAnimatedBurnedCalories = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            Spacer()
            // The custom animatable view to show the calories.
            CountingNumberText(number: animatedCalories)
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
            if Self.hasAnimatedBurnedCalories {
                // If the animation has already played, immediately update without animating.
                animatedCalories = viewModel.currentBurnedCalories
            } else {
                // First-time launch: animate from 0 to the current value.
                animatedCalories = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedCalories = viewModel.currentBurnedCalories
                }
                Self.hasAnimatedBurnedCalories = true
            }
        }
        .onReceive(viewModel.$currentBurnedCalories) { newValue in
            // Animate any new updates to the burned calories.
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedCalories = newValue
            }
        }
    }
}

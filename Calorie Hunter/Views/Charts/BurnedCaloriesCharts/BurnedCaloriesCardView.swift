import SwiftUI

struct BurnedCaloriesCardView: View {
    @StateObject var burnedCaloriesviewModel = BurnedCaloriesViewModel()
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var animatedCalories: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    /// Static flag to ensure the launch animation plays only once per app session.
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
            CountingNumberText(number: animatedCalories)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            BurnedCaloriesProgressView(viewModel: viewModel,
                                       burnedCaloriesViewModel: burnedCaloriesviewModel,
                                       onBurnedCaloriesChange: { })
        }
        .padding(.horizontal)
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .onAppear {
            if Self.hasAnimatedBurnedCalories {
                animatedCalories = burnedCaloriesviewModel.currentBurnedCalories
            } else {
                animatedCalories = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedCalories = burnedCaloriesviewModel.currentBurnedCalories
                }
                Self.hasAnimatedBurnedCalories = true
            }
        }
        .onReceive(burnedCaloriesviewModel.$currentBurnedCalories) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedCalories = newValue
            }
        }
    }
}

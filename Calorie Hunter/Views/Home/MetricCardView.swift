import SwiftUI

struct MetricCardView: View {
    let iconName: String
    let title: String
    let valueText: String
    // Progress bar data
    let current: Double
    let goal: Double
    let gradientColors: [Color]

    @Environment(\.colorScheme) var colorScheme
    @State private var animatedValue: Double = 0

    init(iconName: String,
         title: String,
         valueText: String,
         current: Double,
         goal: Double,
         gradientColors: [Color]) {
        self.iconName = iconName
        self.title = title
        self.valueText = valueText
        self.current = current
        self.goal = goal
        self.gradientColors = gradientColors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            CountingNumberText(number: animatedValue)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            GradientProgressBar(
                current: animatedValue,
                goal: goal,
                gradientColors: gradientColors
            )
        }
        .padding(.horizontal, 8)
        .onAppear {
            animatedValue = 0
            withAnimation(.easeInOut(duration: 1)) {
                animatedValue = current
            }
        }
        .onChange(of: current) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 1)) {
                animatedValue = newValue
            }
        }
        .padding(.horizontal)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct MetricCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricCardView(
            iconName: "flame.fill",
            title: "Burned Calories",
            valueText: "450 kcal",
            current: 450,
            goal: 600,
            gradientColors: [Color.pink, Color.orange]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif

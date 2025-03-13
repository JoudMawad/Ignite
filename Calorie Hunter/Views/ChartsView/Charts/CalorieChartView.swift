import SwiftUI
import Charts

struct CalorieChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    var totalCalories: Int

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let dailyGoal = Int(viewModel.profile?.dailyCalorieGoal ?? 1500)

            ZStack {
                // Outer glow effect
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: size * 0.024)
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.03)

                if totalCalories <= dailyGoal {
                    let caloriesLeft = dailyGoal - totalCalories
                    let progress = Double(caloriesLeft) / Double(dailyGoal)
                    let gradientColors: [Color] = colorScheme == .light ? [Color.white, Color.red, Color.white] : [Color.black, Color.red, Color.black]
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round)
                        )
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(-90))
                    
                    // Center text overlay
                    VStack(spacing: size * 0.05) {
                        Text("\(caloriesLeft) kcal left")
                            .font(.system(size: size * 0.1))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        Text("Goal: \(dailyGoal) kcal")
                            .font(.system(size: size * 0.07))
                            .foregroundColor(.gray)
                    }
                    .padding(size * 0.05)
                } else {
                    let over = totalCalories - dailyGoal
                    let progress = min(Double(over) / Double(dailyGoal), 1.0)

                    // "Over" arc
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.red, Color.red]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round)
                        )
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(-90))
                    
                    // Center text overlay
                    VStack(spacing: size * 0.05) {
                        Text("\(over) kcal")
                            .font(.system(size: size * 0.1))
                            .bold()
                        Text("Over")
                            .font(.system(size: size * 0.07))
                            .foregroundColor(.gray)
                    }
                    .padding(size * 0.05)
                }
            }
            // Force the ZStack to fill the entire GeometryReader and center its content.
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .animation(.easeInOut(duration: 0.5), value: totalCalories)
        }
    }
}

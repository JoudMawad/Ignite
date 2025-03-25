import SwiftUI
import Charts

struct CalorieChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // Total calories consumed (eaten) for the day.
    var totalCalories: Int
    // Total calories burned for the day.
    var burnedCalories: Int

    var body: some View {
        GeometryReader { geometry in
            // Use the smallest dimension to ensure the chart remains circular.
            let size = min(geometry.size.width, geometry.size.height)
            
            // Retrieve base calorie goal and convert values to Double for calculations.
            let baseGoal = Double(viewModel.dailyCalorieGoalValue)
            let B = Double(burnedCalories)
            let C = Double(totalCalories)
            
            // Adjust the goal by adding burned calories.
            let effectiveGoal = baseGoal + B
            // Calculate remaining burned calories in case consumption is lower than burned.
            let burnedRemaining = max(B - C, 0)
            // Calculate remaining base calories; if consumption exceeds burned calories, subtract the difference.
            let baseRemaining = (C <= B) ? baseGoal : max(baseGoal - (C - B), 0)
            // Total remaining calories is the sum of the base and burned portions.
            let leftCalories = baseRemaining + burnedRemaining
            
            // Compute fractions for drawing the progress arcs.
            let baseFraction = baseRemaining / effectiveGoal
            // Only compute burned fraction if any calories were burned.
            let burnedFraction = (B > 0) ? (burnedRemaining / effectiveGoal) : 0
            
            ZStack {
                // Draw the background circle.
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.035)
                    .frame(width: size, height: size)
                
                // Define color gradients for the base and burned sections, adapting to light/dark mode.
                let baseGradient: [Color] = colorScheme == .light ?
                    [Color.white, Color.blue, Color.white] :
                    [Color.black, Color.blue, Color.black]
                let burnedGradient: [Color] = colorScheme == .light ?
                    [Color.red, Color.white, Color.red] :
                    [Color.red, Color.black, Color.red]
                
                // Draw the base portion of the circle.
                Circle()
                    .trim(from: 0, to: CGFloat(baseFraction))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: baseGradient),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90)) // Start progress from top.
                
                // Draw the burned portion right after the base portion.
                Circle()
                    .trim(from: CGFloat(baseFraction), to: CGFloat(baseFraction + burnedFraction))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: burnedGradient),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                // Centered text displaying calories left and the effective goal.
                VStack(spacing: size * 0.04) {
                    Text("\(Int(leftCalories)) kcal left")
                        .font(.system(size: size * 0.1))
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Text("Goal: \(Int(effectiveGoal)) kcal")
                        .font(.system(size: size * 0.07))
                        .foregroundColor(.gray)
                }
                .padding(size * 0.05)
            }
            // Ensure the ZStack fills the available space.
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Animate changes when the combined calories values or goal update.
            .animation(.easeInOut(duration: 0.5), value: totalCalories + burnedCalories + viewModel.dailyCalorieGoalValue)
        }
    }
}

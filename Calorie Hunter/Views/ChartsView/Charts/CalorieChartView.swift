import SwiftUI
import Charts

struct CalorieChartView: View {
    // The user profile view model provides the base daily calorie goal.
    @ObservedObject var viewModel: UserProfileViewModel
    // Use the current color scheme for color adjustments.
    @Environment(\.colorScheme) var colorScheme
    
    // Total calories consumed (eaten) for the day.
    var totalCalories: Int
    // Total calories burned for the day (from BurnedCaloriesViewModel).
    var burnedCalories: Int

    var body: some View {
        GeometryReader { geometry in
            // Determine a square size for our chart.
            let size = min(geometry.size.width, geometry.size.height)
            
            // Base daily goal from profile (G), defaulting to 1500 kcal.
            let baseGoal = Double(viewModel.profile?.dailyCalorieGoal ?? 1500)
            // Calories burned (B) and consumed (C) as Doubles.
            let B = Double(burnedCalories)
            let C = Double(totalCalories)
            
            // Effective goal = base goal + burned calories.
            let effectiveGoal = baseGoal + B
            
            // Compute how much burned credit remains:
            // If consumption (C) is less than burned (B), then all of burned remains.
            // If C exceeds B, then burnedRemaining is zero.
            let burnedRemaining = max(B - C, 0)
            
            // Compute base remaining:
            // If consumption is less than or equal to burned, then the base remains intact.
            // If consumption exceeds burned, then the excess (C - B) is deducted from the base goal.
            let baseRemaining = (C <= B) ? baseGoal : max(baseGoal - (C - B), 0)
            
            // Total calories left equals the sum of remaining base and remaining burned.
            let leftCalories = baseRemaining + burnedRemaining
            
            // Now compute the fraction of the effective goal for each segment.
            // Note: effectiveGoal = baseGoal + B.
            let baseFraction = baseRemaining / effectiveGoal
            let burnedFraction = (B > 0) ? (burnedRemaining / effectiveGoal) : 0
            
            ZStack {
                // --- Full Background ---
                // Draw a background circle representing the full effective goal.
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.035)
                    .frame(width: size, height: size)
                
                // --- Base Remaining Segment ---
                // Draw the base remaining arc from 0 to baseFraction.
                // Use your gradient for the base segment.
                let baseGradient: [Color] = colorScheme == .light ?
                    [Color.white, Color.red, Color.white] :
                    [Color.black, Color.red, Color.black]
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
                    .rotationEffect(.degrees(-90))
                
                // --- Burned Remaining Segment ---
                // Draw the burned segment right after the base segment.
                // This segment represents the remaining burned calories credit.
                Circle()
                    .trim(from: CGFloat(baseFraction), to: CGFloat(baseFraction + burnedFraction))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7), Color.blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                // --- Center Overlay ---
                // Show the "calories left" (baseRemaining + burnedRemaining)
                // and the effective goal.
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
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Animate changes when consumption or burned calories update.
            .animation(.easeInOut(duration: 0.5), value: totalCalories + burnedCalories)
        }
    }
}

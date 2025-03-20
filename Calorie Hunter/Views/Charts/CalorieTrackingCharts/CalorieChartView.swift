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
            let size = min(geometry.size.width, geometry.size.height)
            
            // Use the published dailyCalorieGoalValue directly.
            let baseGoal = Double(viewModel.dailyCalorieGoalValue)
            let B = Double(burnedCalories)
            let C = Double(totalCalories)
            
            let effectiveGoal = baseGoal + B
            let burnedRemaining = max(B - C, 0)
            let baseRemaining = (C <= B) ? baseGoal : max(baseGoal - (C - B), 0)
            let leftCalories = baseRemaining + burnedRemaining
            
            let baseFraction = baseRemaining / effectiveGoal
            let burnedFraction = (B > 0) ? (burnedRemaining / effectiveGoal) : 0
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.035)
                    .frame(width: size, height: size)
                
                let baseGradient: [Color] = colorScheme == .light ?
                    [Color.white, Color.blue, Color.white] :
                    [Color.black, Color.blue, Color.black]
                let burnedGradient: [Color] = colorScheme == .light ?
                    [Color.red, Color.white, Color.red] :
                    [Color.red, Color.black, Color.red]
                
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
            .animation(.easeInOut(duration: 0.5), value: totalCalories + burnedCalories + viewModel.dailyCalorieGoalValue)
        }
    }
}

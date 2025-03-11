import SwiftUI
import Charts

struct CalorieChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    var totalCalories: Int

    var body: some View {
        let dailyGoal = viewModel.dailyCalorieGoal
        
        if totalCalories <= dailyGoal {
            // Normal mode: show calories left.
            let caloriesLeft = dailyGoal - totalCalories
            let progress = Double(caloriesLeft) / Double(dailyGoal)
            let gradientColors: [Color] = {
                if progress > 0 {
                    return [Color.pink, Color.purple, Color.pink]
                } else {
                    return [Color.pink, Color.purple, Color.pink]
                }
            }()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: 10)
                    .frame(width: 290, height: 290)
                    .blur(radius: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradientColors),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 290, height: 290)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(caloriesLeft) kcal left")
                        .font(.title)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    Text("Goal: \(dailyGoal) kcal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        } else {
            // Over goal: show the overflow consumption.
            let over = -(dailyGoal - totalCalories)
            // Calculate progress for the overflow relative to the goal (capped at 1 full circle).
            let progress = min(Double(over) / Double(dailyGoal), 1.0)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.45), lineWidth: 10)
                    .frame(width: 290, height: 290)
                    .blur(radius: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.red, Color.red]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 290, height: 290)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(over) kcal")
                        .font(.title)
                        .bold()
                    Text("Over")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

import SwiftUI
import UIKit
import CoreData

struct CalorieGoalSliderView: View {
    @Environment(\.colorScheme) var colorScheme

    // MARK: – Inputs
    var age: Int
    var height: Double
    var weight: Double
    var gender: String
    /// Bound to the user's weekly weight change goal stored in Core Data.
    @Binding var weeklyChange: Double
    var onCalorieGoalChange: ((Int) -> Void)? = nil

    init(
        age: Int,
        height: Double,
        weight: Double,
        gender: String,
        weeklyChange: Binding<Double>,
        onCalorieGoalChange: ((Int) -> Void)? = nil
    ) {
        self.age = age
        self.height = height
        self.weight = weight
        self.gender = gender
        self._weeklyChange = weeklyChange
        self.onCalorieGoalChange = onCalorieGoalChange
    }

    // MARK: – Computed
    private var bmr: Double {
        BMRCalculator.computeBMR(
            forWeight: weight,
            age: Double(age),
            height: height,
            gender: gender
        )
    }
    private var dailyCalorieGoal: Int {
        Int((bmr + (weeklyChange * 7700/7)).rounded())
    }

    var body: some View {
        VStack(spacing: 10) {
            // — Header row
            HStack {
                Text("Weight loss/gain per week")
                    .font(.headline)
            }
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 8)

            // — Slider track + thumb
            GeometryReader { geo in
                let W = geo.size.width
                let centerX = W / 2
                let norm = CGFloat((weeklyChange + 0.5) / 1.0)
                let thumbX = norm * W
                let delta = thumbX - centerX

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    // Gradient segment
                    if delta != 0 {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        delta > 0 ? Color.green : Color.red,
                                        (delta > 0 ? Color.green : Color.red).opacity(0.5)
                                    ]),
                                    startPoint: delta > 0 ? .trailing : .leading,
                                    endPoint:   delta > 0 ? .leading : .trailing
                                )
                            )
                            .frame(width: abs(delta), height: 4)
                            .offset(x: delta > 0 ? centerX : centerX + delta)
                    }

                    // Thumb
                    Circle()
                        .fill(colorScheme == .dark ? .black : .white)
                        .frame(width: 18, height: 18)
                        .shadow(radius: 1, y: 0.5)
                        .offset(x: thumbX - 9)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            let x = min(max(0, g.location.x), W)
                            let raw = Double(x / W) - 0.5
                            let snapped = (raw / 0.1).rounded() * 0.1
                            if snapped != weeklyChange {
                                weeklyChange = snapped
                                UIImpactFeedbackGenerator(style: .light)
                                    .impactOccurred()
                                onCalorieGoalChange?(dailyCalorieGoal)
                            }
                        }
                )
            }
            .frame(width: 250, height: 30)

            // — Sub-labels
            HStack {
                Text(String(format: "%+.1f kg/wk", weeklyChange))
                    .font(.caption2)
                Spacer()
                Text("\(dailyCalorieGoal) kcal")
                    .font(.caption2)
            }
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 8)
        }
        .frame(width: 280, height: 100)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
        )
        
    }
}

struct CalorieGoalSliderView_Previews: PreviewProvider {
    @State static private var previewWeeklyChange: Double = 0.0
    static var previews: some View {
        Group {
            CalorieGoalSliderView(
                age: 30, height: 175, weight: 70, gender: "male",
                weeklyChange: $previewWeeklyChange
            ) { newCal in
                print("New cal goal: \(newCal)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)

            CalorieGoalSliderView(
                age: 30, height: 175, weight: 70, gender: "male",
                weeklyChange: $previewWeeklyChange
            ) { newCal in
                print("New cal goal: \(newCal)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}

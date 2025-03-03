//
//  CalorieChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import SwiftUI
import Charts

struct CalorieChartView: View {
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Int = 1500
    var totalCalories: Int
    let goalCalories = 1500 // ✅ Goal set to 1500 kcal

    var body: some View {
        let progress = Double(totalCalories) / Double(goalCalories)

        ZStack {
            // ✅ Outer Glow for the Chart
            Circle()
                .stroke(Color.orange.opacity(0.3), lineWidth: 12)
                .frame(width: 290, height: 290)
                .blur(radius: 8)

            // ✅ Progress Circle
            Circle()
                .trim(from: 0, to: CGFloat(progress > 1 ? 1 : progress)) // ✅ Prevent overflow
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round)) // ✅ Rounded edges
                .frame(width: 290, height: 290)
                .rotationEffect(.degrees(-90))

            // ✅ Text Inside Chart
            VStack {
                            Text("\(totalCalories) kcal")
                                .font(.title)
                                .bold()
                            Text("Goal: \(dailyCalorieGoal) kcal") // ✅ Uses dynamic user-set goal
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
        }
    }
}

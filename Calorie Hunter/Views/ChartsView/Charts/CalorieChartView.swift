//
//  CalorieChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import SwiftUI
import Charts

struct CalorieChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    var totalCalories: Int

    var body: some View {
        let progress = Double(totalCalories) / Double(viewModel.dailyCalorieGoal)
        let gradientColors: [Color] = progress > 1
            ? [Color.red, Color.red]  // Overeating -> Full red
            : [Color.green, Color.yellow, Color.orange, Color.green]  // Gradual transition

        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.45), lineWidth: 10)
                .frame(width: 290, height: 290)
                .blur(radius: 8)

            Circle()
                .trim(from: 0, to: CGFloat(progress > 1 ? 1 : progress))
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
                Text("\(totalCalories) kcal")
                    .font(.title)
                    .bold()
                Text("Goal: \(viewModel.dailyCalorieGoal) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}


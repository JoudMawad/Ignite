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

        ZStack {
            Circle()
                .stroke(Color.orange.opacity(0.3), lineWidth: 12)
                .frame(width: 290, height: 290)
                .blur(radius: 8)

            Circle()
                .trim(from: 0, to: CGFloat(progress > 1 ? 1 : progress))
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
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

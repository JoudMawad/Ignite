//
//  StepsProgressView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 15.03.25.
//

import SwiftUI

struct BurnedCaloriesProgressView: View {
    // Observed user profile for accessing goal values.
    @ObservedObject var viewModel: UserProfileViewModel
    // Observed view model tracking burned calories.
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    // Closure called when burned calories change (currently unused).
    var onBurnedCaloriesChange: () -> Void = {}
    
    /// Retrieves the user's daily burned calories goal.
    private var dailyBurnedCaloriesGoal: Int {
        viewModel.dailyBurnedCaloriesGoalValue
    }
    
    /// Calculates the progress ratio based on current burned calories relative to the goal.
    /// - Returns: A value between 0 and 1 representing the percentage progress.
    private var progress: CGFloat {
        // Avoid division by zero by ensuring the goal is non-zero.
        guard dailyBurnedCaloriesGoal != 0 else { return 0 }
        let caloriesRange = CGFloat(dailyBurnedCaloriesGoal)
        let currentOffset = CGFloat(burnedCaloriesViewModel.currentBurnedCalories)
        // Clamp progress between 0 and 1.
        return min(max(currentOffset / caloriesRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                // GeometryReader provides container size for dynamic progress bar width.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Base progress bar background for context.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
                        // Foreground gradient progress bar indicating current progress.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            // Calculate width based on available width multiplied by the progress ratio.
                            .frame(width: max(geometry.size.width * progress, 5), height: 10)
                    }
                }
                // Fix the height of the geometry reader to match the bar's height.
                .frame(height: 10)
                
                // Spacer to push content to the left.
                Spacer()
            }
        }
    }
}

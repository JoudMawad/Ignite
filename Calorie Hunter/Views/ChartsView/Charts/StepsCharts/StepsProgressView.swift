//
//  StepsProgressView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 15.03.25.
//

import SwiftUI

struct StepsProgressView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var stepsViewModel: StepsViewModel
    var onStepsChange: () -> Void = {}

    // Read the steps goal from the published property.
    private var dailyStepsGoal: Int {
        viewModel.dailyStepsGoalValue
    }
    
    private var progress: CGFloat {
        guard dailyStepsGoal != 0 else { return 0 }
        let stepsRange = CGFloat(dailyStepsGoal)
        let currentOffset = CGFloat(stepsViewModel.currentSteps)
        return min(max(currentOffset / stepsRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geometry.size.width * progress, 5), height: 10)
                    }
                }
                .frame(height: 10)
                
                Spacer()
            }
        }
    }
}

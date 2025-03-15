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
    
    // Computed properties that retrieve values from the Core Data profile.
    private var dailyStepsGoal: Int32 {
        viewModel.profile?.dailyStepsGoal ?? 10000
    }
    
    
    // Calculate progress between start and goal weight.
    private var progress: CGFloat {
        guard dailyStepsGoal != 0 else { return 0 }
        let stepsRange = CGFloat(dailyStepsGoal - 0)
        let currentOffset = CGFloat(stepsViewModel.currentSteps - 0)
        return min(max(currentOffset / stepsRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background progress bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
                        // Gradient progress bar
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


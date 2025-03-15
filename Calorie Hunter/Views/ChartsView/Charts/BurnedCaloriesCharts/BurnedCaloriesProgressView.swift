//
//  StepsProgressView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 15.03.25.
//

import SwiftUI

struct BurnedCaloriesProgressView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    var onBurnedCaloriesChange: () -> Void = {}
    
    // Computed properties that retrieve values from the Core Data profile.
    private var dailyBurnedCaloriesGoal: Int32 {
        viewModel.profile?.dailyBurnedCaloriesGoal ?? 500
    }
    
    
    // Calculate progress between start and goal weight.
    private var progress: CGFloat {
        guard dailyBurnedCaloriesGoal != 0 else { return 0 }
        let caloriesRange = CGFloat(dailyBurnedCaloriesGoal)
        let currentOffset = CGFloat(burnedCaloriesViewModel.currentBurnedCalories - 0)
        return min(max(currentOffset / caloriesRange, 0), 1)
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
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
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


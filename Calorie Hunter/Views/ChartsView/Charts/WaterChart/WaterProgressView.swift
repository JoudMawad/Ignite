//
//  WaterDropProgress.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 10.03.25.
//

import SwiftUI

struct WaterProgressView: View {
    @ObservedObject var waterViewModel: WaterViewModel
    
    /// The user's daily water goal in liters.
    var dailyGoal: Double
    
    // Computed property for today's water amount
    private var currentWater: Double {
        waterViewModel.waterAmount(for: Date())
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row: icon, "Water x.xl" label, plus/minus
            HStack {
                
                Text("Water \(String(format: "%.1f", currentWater))l")
                    .font(.headline)
                
                Spacer()
                
                // Minus button
                Button {
                    waterViewModel.adjustWaterAmount(by: -0.1, for: Date())
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                // Plus button
                Button {
                    waterViewModel.adjustWaterAmount(by: 0.1, for: Date())
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Bottom row: progress bar + daily goal label on the far right
            HStack {
                // Progress bar
                ProgressView(value: currentWater, total: dailyGoal)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
                
                // Show daily goal on the far right
                Text("\(String(format: "%.1f", dailyGoal))l")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

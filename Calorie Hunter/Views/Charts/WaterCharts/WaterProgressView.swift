import SwiftUI
import UIKit
import HealthKit // if not already present for other imports

struct WaterProgressView: View {
    // ViewModel to manage and update water intake data.
    @ObservedObject var waterViewModel: WaterViewModel
    
    /// The user profile view model, to track dynamic goal changes.
    @ObservedObject var profileViewModel: UserProfileViewModel
    
    /// Haptic feedback generator for tap interactions.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // Compute the water amount for the current day, using the view model's published value.
    private var currentWater: Double {
        waterViewModel.currentWaterAmount
    }
    
    // Calculate the progress as a fraction of current water vs. the daily goal.
    // The result is clamped between 0 and 1.
    private var progress: CGFloat {
        guard profileViewModel.dailyWaterGoalValue > 0 else { return 0 }
        return min(max(CGFloat(currentWater / profileViewModel.dailyWaterGoalValue), 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Top row: Displays the "Water" label, current intake, and adjustment buttons.
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Water")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    // Display the current water intake formatted to one decimal place.
                    Text("\(String(format: "%.1f", currentWater))L")
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(.blue)
                }
                Spacer()
                // Buttons to adjust the water intake.
                HStack(spacing: 16) {
                    Button {
                        tapFeedback.impactOccurred()
                        // Decrease water intake by 0.1L for today.
                        waterViewModel.adjustWaterAmount(by: -0.1, for: Date())
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        tapFeedback.impactOccurred()
                        // Increase water intake by 0.1L for today.
                        waterViewModel.adjustWaterAmount(by: 0.1, for: Date())
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            // Bottom row: Contains the progress bar and the daily goal text.
            HStack(spacing: 8) {
                // The progress bar is constrained to a fixed width.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background capsule for the progress bar.
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 8)
                        
                        // Foreground capsule that indicates current progress.
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            // Width is based on the computed progress fraction.
                            .frame(width: geometry.size.width * progress, height: 8)
                            // Animate changes in water intake smoothly.
                            .animation(.easeInOut(duration: 0.3), value: currentWater)
                    }
                }
                .frame(width: 295, height: 8)
                
                // Display the daily water goal formatted to one decimal place.
                Text("\(String(format: "%.1f", profileViewModel.dailyWaterGoalValue))L")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
        }
    }
}

import SwiftUI

struct WaterProgressView: View {
    @ObservedObject var waterViewModel: WaterViewModel
    
    /// The user's daily water goal in liters.
    var dailyGoal: Double
    
    // Computed property for today's water amount.
    private var currentWater: Double {
        waterViewModel.waterAmount(for: Date())
    }
    
    // Compute progress (0...1) based on current water vs daily goal.
    private var progress: CGFloat {
        guard dailyGoal > 0 else { return 0 }
        return min(max(CGFloat(currentWater / dailyGoal), 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Top row: "Water" label, current water amount, plus/minus buttons.
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Water")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("\(String(format: "%.1f", currentWater))L")
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(.blue)
                }
                Spacer()
                HStack(spacing: 16) {
                    Button {
                        waterViewModel.adjustWaterAmount(by: -0.1, for: Date())
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        waterViewModel.adjustWaterAmount(by: 0.1, for: Date())
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            // Bottom row: progress bar on the left and daily goal text on the right.
            HStack(spacing: 8) {
                // Constrain the progress bar to a fixed maximum width.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) { // Use .leading instead of .trailing
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentWater)
                    }
                }
                .frame(width: 295, height: 8)
                
                // Daily goal text.
                Text("\(String(format: "%.1f", dailyGoal))L")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
        }
    }
}

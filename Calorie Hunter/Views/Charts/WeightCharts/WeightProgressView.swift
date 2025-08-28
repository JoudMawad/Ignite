import SwiftUI

struct WeightProgressView: View {
    // Access the user profile data (start, current, and goal weights).
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var goalsViewModel: GoalsViewModel
    // Optional closure to trigger actions when weight changes (currently unused).
    var onWeightChange: () -> Void = {}
    
    /// The starting weight from the user profile.
    private var startWeight: Double {
        userProfileViewModel.startWeightValue
    }
    
    /// The current weight from the user profile.
    private var currentWeight: Double {
        userProfileViewModel.currentWeightValue
    }
    
    /// The goal weight from the user profile.
    private var goalWeight: Double {
        goalsViewModel.goalWeightValue
    }
    
    /// Calculate the progress as a fraction of the weight difference achieved.
    /// The progress is computed as (currentWeight - startWeight) divided by (goalWeight - startWeight),
    /// and then clamped between 0 and 1.
    private var progress: CGFloat {
        guard goalWeight != startWeight else { return 0 }
        let weightRange = CGFloat(goalWeight - startWeight)
        let currentOffset = CGFloat(currentWeight - startWeight)
        return min(max(currentOffset / weightRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                // Display the starting weight.
                Text("\(String(format: "%.1f", startWeight)) kg")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // GeometryReader to adapt the progress bar width based on available space.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background of the progress bar.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
                        // Foreground progress bar with a cyan-to-blue gradient.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            // Set width based on the computed progress; enforce a minimum width for visibility.
                            .frame(width: max(geometry.size.width * progress, 5), height: 10)
                    }
                }
                .frame(height: 10)
                
                Spacer()
                
                // Display the goal weight.
                Text("\(String(format: "%.1f", goalWeight)) kg")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

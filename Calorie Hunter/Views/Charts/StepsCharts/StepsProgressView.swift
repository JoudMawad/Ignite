import SwiftUI

struct StepsProgressView: View {
    // Access the user's profile data, including the daily steps goal.
    @ObservedObject var viewModel: UserProfileViewModel
    // Access the steps data from the steps view model.
    @ObservedObject var stepsViewModel: StepsViewModel
    // Closure to handle additional actions when steps change (currently unused).
    var onStepsChange: () -> Void = {}

    /// Retrieve the daily steps goal from the user profile.
    private var dailyStepsGoal: Int {
        viewModel.dailyStepsGoalValue
    }
    
    /// Compute the progress as a fraction of current steps to the daily goal.
    /// Returns a value between 0 and 1, ensuring division safety and clamping the result.
    private var progress: CGFloat {
        guard dailyStepsGoal != 0 else { return 0 }
        let stepsRange = CGFloat(dailyStepsGoal)
        let currentOffset = CGFloat(stepsViewModel.currentSteps)
        // Clamp the progress value to ensure it stays within 0 and 1.
        return min(max(currentOffset / stepsRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                // GeometryReader is used to get the available width for the progress bar.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar for context.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
                        // Foreground bar representing the current progress,
                        // using a gradient for visual appeal.
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            // Width is determined by the progress fraction relative to the available width,
                            // with a minimum width of 5 for visibility.
                            .frame(width: max(geometry.size.width * progress, 5), height: 10)
                    }
                }
                // Fix the height of the GeometryReader to match the bar's height.
                .frame(height: 10)
                
                // Spacer pushes the progress bar to the left.
                Spacer()
            }
        }
    }
}

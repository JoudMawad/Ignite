import SwiftUI

struct WeightProgressView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    var onWeightChange: () -> Void = {}
    
    // Computed properties that retrieve values from the Core Data profile.
    private var startWeight: Double {
        viewModel.profile?.startWeight ?? 70.0
    }
    
    private var currentWeight: Double {
        viewModel.profile?.currentWeight ?? 70.0
    }
    
    private var goalWeight: Double {
        viewModel.profile?.goalWeight ?? 65.0
    }
    
    // Calculate progress between start and goal weight.
    private var progress: CGFloat {
        guard goalWeight != startWeight else { return 0 }
        let weightRange = CGFloat(goalWeight - startWeight)
        let currentOffset = CGFloat(currentWeight - startWeight)
        return min(max(currentOffset / weightRange, 0), 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(String(format: "%.1f", startWeight)) kg")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
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
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geometry.size.width * progress, 5), height: 10)
                    }
                }
                .frame(height: 10)
                
                Spacer()
                
                Text("\(String(format: "%.1f", goalWeight)) kg")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            
            // Uncomment this section if you want to allow user weight adjustments.
           /* HStack {
                Button(action: {
                    withAnimation {
                        if let current = viewModel.profile?.currentWeight {
                            let newWeight = current - 0.1
                            viewModel.updateCurrentWeight(newWeight)
                            onWeightChange()
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                
                Text("\(String(format: "%.1f", currentWeight)) kg")
                    .font(.headline)
                    .padding(.horizontal, 10)
                
                Button(action: {
                    withAnimation {
                        if let current = viewModel.profile?.currentWeight {
                            let newWeight = current + 0.1
                            viewModel.updateCurrentWeight(newWeight)
                            onWeightChange()
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding(.top, 5)
            */
        }
    }
}

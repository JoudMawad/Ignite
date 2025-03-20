import SwiftUI

struct WeightProgressView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    var onWeightChange: () -> Void = {}
    
    private var startWeight: Double {
        viewModel.startWeightValue
    }
    
    private var currentWeight: Double {
        viewModel.currentWeightValue
    }
    
    private var goalWeight: Double {
        viewModel.goalWeightValue
    }
    
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
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)
                        
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
        }
    }
}

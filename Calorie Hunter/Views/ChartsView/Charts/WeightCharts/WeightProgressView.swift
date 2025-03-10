import SwiftUI

struct WeightProgressView: View {
    var startWeight: Double
    @ObservedObject var viewModel: UserProfileViewModel
    var onWeightChange: () -> Void

    private var progress: CGFloat {
        guard viewModel.goalWeight != startWeight else { return 0 }
        let weightRange = CGFloat(viewModel.goalWeight - startWeight)
        let currentOffset = CGFloat(viewModel.currentWeight - startWeight)
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
                        // Background Progress Bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 10)

                        // Optimized Gradient Progress Bar (direct fill & clip)
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

                Text("\(String(format: "%.1f", viewModel.goalWeight)) kg")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
           /* HStack {
                Button(action: {
                    withAnimation {
                        viewModel.currentWeight -= 0.1
                        viewModel.updateCurrentWeight(viewModel.currentWeight)
                        onWeightChange()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }

                Text("\(String(format: "%.1f", viewModel.currentWeight)) kg")
                    .font(.headline)
                    .padding(.horizontal, 10)

                Button(action: {
                    withAnimation {
                        viewModel.currentWeight += 0.1
                        viewModel.updateCurrentWeight(viewModel.currentWeight)
                        onWeightChange()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding(.top, 5)*/
        }
        .padding()
        // Uncomment the next line if you want to render the chart offscreen for further performance gains.
        // .drawingGroup()
    }
}

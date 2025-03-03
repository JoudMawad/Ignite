import SwiftUI

struct WeightChartView: View {
    var startWeight: Int
    @Binding var currentWeight: Int
    var goalWeight: Int
    var onWeightChange: () -> Void

    // ✅ Calculate progress correctly
    private var progress: CGFloat {
        guard goalWeight != startWeight else { return 0 }
        let weightRange = CGFloat(goalWeight - startWeight)
        let currentOffset = CGFloat(currentWeight - startWeight)
        return min(max(currentOffset / weightRange, 0), 1) // Ensure progress is between 0 and 1
    }

    var body: some View {
        VStack {
            // ✅ Start & Goal Weight Labels
            HStack {
                Text("\(startWeight) kg") // Start weight (left side)
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background Progress Bar
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 10)
                            .foregroundColor(Color.gray.opacity(0.3))

                        // ✅ Ensure blue bar always renders
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: max(geometry.size.width * progress, 5), height: 10) // Ensure min width
                            .foregroundColor(.blue)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 10)

                Spacer()

                Text("\(goalWeight) kg") // Goal weight (right side)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // ✅ Current Weight with Interactive Buttons
            HStack {
                // Decrease Button
                Button(action: {
                            currentWeight -= 1
                            onWeightChange()  // ✅ Ensure weight change is saved
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }

                // ✅ Display Current Weight
                Text("\(currentWeight) kg")
                    .font(.headline)
                    .padding(.horizontal, 10)

                // Increase Button
                Button(action: {
                            currentWeight += 1
                            onWeightChange()  // ✅ Fix: Ensure update is saved
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding(.top, 5)
        }
        .padding()
    }
}

#Preview {
    WeightChartView(
        startWeight: 100,
        currentWeight: .constant(90),
        goalWeight: 80,
        onWeightChange: {}
    )
}

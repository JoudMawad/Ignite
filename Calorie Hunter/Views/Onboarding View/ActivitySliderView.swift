// ActivitySliderView.swift

import SwiftUI

struct ActivitySliderView: View {
    @Environment(\.colorScheme) private var colorScheme

    /// Bound to the current selection (0…3).
    @Binding var level: ActivityLevel

    /// Fires whenever the user picks a new level.
    var onLevelChange: ((ActivityLevel) -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            // — Header row
            HStack {
                Text("Activity")
                    .font(.headline)
                Spacer()
                Text(level.title)
                    .font(.subheadline)
            }
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 12)

            // — Custom slider
            GeometryReader { geo in
                let W = geo.size.width
                let maxIndex = ActivityLevel.allCases.count - 1
                let norm = CGFloat(level.rawValue) / CGFloat(maxIndex)
                let thumbX = norm * W

                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    // Filled portion
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: thumbX, height: 4)
                    
                    // Thumb
                    Circle()
                        .fill(colorScheme == .dark ? .black : .white)
                        .frame(width: 18, height: 18)
                        .shadow(radius: 1, y: 0.5)
                        .offset(x: thumbX - 9)
                }
                .contentShape(Rectangle()) // expand hit area
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            let x = min(max(0, g.location.x), W)
                            // snap into one of four buckets
                            let rawIndex = (x / W) * CGFloat(maxIndex)
                            let snapped = Int(rawIndex.rounded())
                            let newLevel = ActivityLevel(rawValue: snapped)!
                            if newLevel != level {
                                level = newLevel
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onLevelChange?(newLevel)
                            }
                        }
                )
            }
            .frame(height: 30)
            .padding(.horizontal, 43)

            // — Ticks and labels under the track
            HStack {
                ForEach(ActivityLevel.allCases) { lvl in
                    Spacer()
                    VStack(spacing: 4) {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(lvl == level ? Color.blue : Color.gray.opacity(0.5))
                        Text(lvl.title)
                            .font(.caption2)
                    }
                    Spacer()
                }
            }
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, -2)
        }
        .frame(maxWidth: 350)
        .padding(.vertical, 16)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
        )
    }
}

struct ActivitySliderView_Previews: PreviewProvider {
    @State static private var previewLevel: ActivityLevel = .sedentary

    static var previews: some View {
        ActivitySliderView(level: $previewLevel) { newLevel in
            // Preview callback (no-op)
            print("Selected level: \(newLevel)")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.light)

        ActivitySliderView(level: $previewLevel)
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
    }
}

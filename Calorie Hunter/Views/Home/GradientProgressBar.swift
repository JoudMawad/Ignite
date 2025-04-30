import SwiftUI

/// A reusable, gradient-backed progress bar.
/// You can either pass in a raw `progress` (0…1) or supply `current`/`goal` values.
struct GradientProgressBar: View {
    // MARK: Configuration
    var progress: CGFloat          // 0…1
    var gradientColors: [Color]    // e.g. [Color.pink, Color.orange]
    var height: CGFloat = 10
    var cornerRadius: CGFloat = 10
    
    init(progress: CGFloat,
         gradientColors: [Color],
         height: CGFloat = 10,
         cornerRadius: CGFloat = 10) {
        self.progress = min(max(progress, 0), 1)
        self.gradientColors = gradientColors
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: max(geo.size.width * progress, height),
                           height: height)
            }
        }
        .frame(height: height)
    }
}

extension GradientProgressBar {
    /// Compute `progress` from `current` and `goal`
    init(current: Double,
         goal: Double,
         gradientColors: [Color],
         height: CGFloat = 10,
         cornerRadius: CGFloat = 10) {
        let pct: CGFloat
        if goal <= 0 { pct = 0 }
        else { pct = min(max(CGFloat(current / goal), 0), 1) }
        self.init(progress: pct,
                  gradientColors: gradientColors,
                  height: height,
                  cornerRadius: cornerRadius)
    }
}

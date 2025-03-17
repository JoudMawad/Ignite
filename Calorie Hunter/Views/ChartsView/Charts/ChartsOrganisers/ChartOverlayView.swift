import SwiftUI

struct ChartOverlayView: View {
    let positions: [CGFloat]
    let color: Color
    let rectangleWidth: CGFloat
    let rectangleHeight: CGFloat
    let yPosition: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(positions, id: \.self) { x in
                Rectangle()
                    .frame(width: rectangleWidth, height: rectangleHeight)
                    .foregroundColor(color)
                    .blendMode(.normal)
                    .position(x: x, y: yPosition)
            }
        }
    }
}

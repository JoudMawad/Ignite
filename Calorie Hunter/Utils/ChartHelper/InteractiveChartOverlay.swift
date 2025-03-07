import SwiftUI
import Charts

/// A simple model for overlay data.
struct OverlayData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

/// A reusable overlay view for showing an interactive marker with haptics.
struct InteractiveChartOverlay: View {
    var proxy: ChartProxy
    var formattedData: [OverlayData]
    @Binding var selectedEntry: OverlayData?
    var markerColor: Color
    var labelColor: Color

    var body: some View {
        GeometryReader { geo in
            if let plotAnchor = proxy.plotFrame {
                let chartFrame = geo[plotAnchor]
                ZStack {
                    // If an entry is selected, show the marker and label.
                    if let selected = selectedEntry {
                        let markerX = proxy.position(forX: selected.label) ?? 0
                        let markerY = proxy.position(forY: selected.value) ?? 0
                        
                        Circle()
                            .fill(markerColor)
                            .frame(width: 10, height: 10)
                            .position(
                                x: markerX + chartFrame.origin.x,
                                y: markerY + chartFrame.origin.y
                            )
                        
                        Text("\(selected.value, specifier: "%.0f")")
                            .font(.caption)
                            .padding(5)
                            .foregroundStyle(labelColor)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                            .offset(x: 0, y: -30)
                            .position(
                                x: markerX + chartFrame.origin.x,
                                y: markerY + chartFrame.origin.y
                            )
                    }
                    
                    // Transparent overlay to capture drag/tap gestures.
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let xLocation = value.location.x - chartFrame.origin.x
                                    var closestEntry: OverlayData?
                                    var smallestDistance: CGFloat = .infinity
                                    
                                    for entry in formattedData {
                                        if let entryX = proxy.position(forX: entry.label) {
                                            let distance = abs(entryX - xLocation)
                                            if distance < smallestDistance {
                                                smallestDistance = distance
                                                closestEntry = entry
                                            }
                                        }
                                    }
                                    
                                    if let closestEntry = closestEntry {
                                        if selectedEntry?.label != closestEntry.label {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                        selectedEntry = closestEntry
                                    }
                                }
                                .onEnded { _ in
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    selectedEntry = nil
                                }
                        )
                }
            } else {
                EmptyView()
            }
        }
    }
}

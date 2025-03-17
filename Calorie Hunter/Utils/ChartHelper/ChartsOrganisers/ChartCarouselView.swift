import SwiftUI

struct ChartCarouselView: View {
    let charts: [AnyView]  // Type erasure for flexibility
    @State private var currentIndex: Int = 1  // Start at index 1 for seamless looping

    private var loopedCharts: [AnyView] {
        guard charts.count > 1, let first = charts.first, let last = charts.last else {
            return charts
        }
        return [AnyView(last)] + charts + [AnyView(first)]
    }

    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(loopedCharts.indices, id: \.self) { index in
                    GeometryReader { proxy in
                        let minX = proxy.frame(in: .global).minX
                        let screenWidth = UIScreen.main.bounds.width
                        let progress = min(max(abs(minX) / screenWidth, 0), 1) // 0 (center) to 1 (fully swiped)
                        let scale = 1.0 + (0.05 * (1 - progress)) // Scaling starts immediately on swipe

                        loopedCharts[index]
                            .frame(width: screenWidth * 0.85, height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5)
                            .scaleEffect(scale)
                            .opacity(1.0 - (0.1 * progress)) // Slight fade effect when swiping
                            .animation(.easeInOut(duration: 0.4), value: minX)  // Animation applies immediately on movement
                            .tag(index)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 400)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 420)
            .onChange(of: currentIndex) { _, newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if newValue == 0 {
                        currentIndex = loopedCharts.count - 2
                    } else if newValue == loopedCharts.count - 1 {
                        currentIndex = 1
                    }
                }
            }

            PageControl(numberOfPages: charts.count, currentIndex: Binding(
                get: { currentIndex == 0 ? charts.count - 1 : (currentIndex == loopedCharts.count - 1 ? 0 : currentIndex - 1) },
                set: { currentIndex = $0 + 1 }
            ))
        }
    }
}

// MARK: - Page Indicator Dots
struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentIndex: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.5))
                    .frame(width: index == currentIndex ? 12 : 9, height: index == currentIndex ? 12 : 9)
                    .scaleEffect(index == currentIndex ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.4), value: currentIndex)
                    .onTapGesture {
                        withAnimation {
                            currentIndex = index
                        }
                    }
            }
        }
        .padding(.top, 1)
    }
}

// MARK: - Preview
#Preview {
    ChartCarouselView(charts: [
        AnyView(Text("Sample Chart 1").frame(height: 400).background(Color.red).cornerRadius(20)),
        AnyView(Text("Sample Chart 2").frame(height: 400).background(Color.green).cornerRadius(20)),
        AnyView(Text("Sample Chart 3").frame(height: 400).background(Color.blue).cornerRadius(20))
    ])
}

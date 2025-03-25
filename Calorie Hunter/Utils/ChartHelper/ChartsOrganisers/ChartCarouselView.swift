import SwiftUI

// ChartCarouselView displays a carousel (scrollable paging view) of charts.
// It uses type-erased AnyView for flexibility so you can pass in any kind of view.
struct ChartCarouselView: View {
    // An array of charts to display.
    let charts: [AnyView]
    // The current index being displayed. We start at 1 to allow for seamless looping.
    @State private var currentIndex: Int = 1

    // This computed property creates a "looped" array of charts.
    // It adds the last chart to the beginning and the first chart to the end.
    // This trick allows the carousel to loop seamlessly.
    private var loopedCharts: [AnyView] {
        guard charts.count > 1, let first = charts.first, let last = charts.last else {
            return charts
        }
        return [AnyView(last)] + charts + [AnyView(first)]
    }

    var body: some View {
        VStack {
            // TabView allows paging through views.
            TabView(selection: $currentIndex) {
                // Loop over each chart in our loopedCharts array.
                ForEach(loopedCharts.indices, id: \.self) { index in
                    GeometryReader { proxy in
                        // Calculate the horizontal offset to determine swipe progress.
                        let minX = proxy.frame(in: .global).minX
                        // Get the screen width for reference.
                        let screenWidth = UIScreen.main.bounds.width
                        // Calculate progress based on how far the view has been swiped.
                        // progress ranges from 0 (centered) to 1 (fully swiped).
                        let progress = min(max(abs(minX) / screenWidth, 0), 1)
                        // Scale the view slightly when swiped to create a dynamic effect.
                        let scale = 1.0 + (0.05 * (1 - progress))
                        
                        // Display the current chart with some styling.
                        loopedCharts[index]
                            .frame(width: screenWidth * 0.85, height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5)
                            .scaleEffect(scale)
                            .opacity(1.0 - (0.1 * progress)) // Slight fade when swiping.
                            .animation(.easeInOut(duration: 0.4), value: minX)
                            .tag(index)
                    }
                    // Set a consistent frame for each page.
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 400)
                }
            }
            // Use a PageTabViewStyle to hide the default page indicator.
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 420)
            // When the current index changes, adjust it if it hits the looped boundaries.
            .onChange(of: currentIndex) { _, newValue in
                // Delay a bit for a smoother transition.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // If we're at the first (fake) page, jump to the real last page.
                    if newValue == 0 {
                        currentIndex = loopedCharts.count - 2
                    // If we're at the last (fake) page, jump to the real first page.
                    } else if newValue == loopedCharts.count - 1 {
                        currentIndex = 1
                    }
                }
            }
            
            // Display the custom page control (indicator dots) below the carousel.
            PageControl(numberOfPages: charts.count, currentIndex: Binding(
                get: {
                    // Adjust the index for the page control.
                    currentIndex == 0 ? charts.count - 1 :
                    (currentIndex == loopedCharts.count - 1 ? 0 : currentIndex - 1)
                },
                set: { currentIndex = $0 + 1 }
            ))
        }
    }
}

// MARK: - Page Indicator Dots

// PageControl displays a row of dots indicating the current page.
struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentIndex: Int

    var body: some View {
        HStack(spacing: 10) {
            // Create a dot for each page.
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    // Fill the current dot with blue, and the others with a lighter gray.
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.5))
                    // Adjust the size of the current dot.
                    .frame(width: index == currentIndex ? 12 : 9, height: index == currentIndex ? 12 : 9)
                    // Slightly scale the current dot for emphasis.
                    .scaleEffect(index == currentIndex ? 1.1 : 1.0)
                    // Animate the change smoothly.
                    .animation(.easeInOut(duration: 0.4), value: currentIndex)
                    // Allow tapping on a dot to change the page.
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
    // Preview the ChartCarouselView with three sample charts.
    ChartCarouselView(charts: [
        AnyView(Text("Sample Chart 1")
            .frame(height: 400)
            .background(Color.red)
            .cornerRadius(20)),
        AnyView(Text("Sample Chart 2")
            .frame(height: 400)
            .background(Color.green)
            .cornerRadius(20)),
        AnyView(Text("Sample Chart 3")
            .frame(height: 400)
            .background(Color.blue)
            .cornerRadius(20))
    ])
}

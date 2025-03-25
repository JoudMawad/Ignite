import SwiftUI

/// A reusable custom card view that can wrap any content and apply a consistent styling.
struct CustomCard<Content: View>: View {
    // The content to be displayed within the card.
    let content: Content
    // The background color of the card.
    let backgroundColor: Color
    // The corner radius for rounded corners.
    let cornerRadius: CGFloat
    // Optional width and height for the card.
    let width: CGFloat?
    let height: CGFloat?

    /// Initializes a new custom card view.
    /// - Parameters:
    ///   - backgroundColor: The color to use as the card's background. Default is white.
    ///   - width: Optional width for the card.
    ///   - height: Optional height for the card.
    ///   - cornerRadius: The corner radius for the card. Default is 15.
    ///   - content: A view builder that creates the content to display inside the card.
    init(backgroundColor: Color = .white,
         width: CGFloat? = nil,
         height: CGFloat? = nil,
         cornerRadius: CGFloat = 15,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        // Wrap the content with padding and a fixed frame if provided.
        content
            .padding()
            .frame(width: width, height: height)
            // Apply a background using a rectangle filled with the specified color.
            .background(
                Rectangle()
                    .fill(backgroundColor)
            )
            // Round the corners using the provided corner radius.
            .cornerRadius(cornerRadius)
            // Add a subtle shadow for depth.
            .shadow(radius: 5)
    }
}

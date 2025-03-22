import SwiftUI

struct CustomCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let width: CGFloat?
    let height: CGFloat?

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
        content
            .padding()
            .frame(width: width, height: height)
            .background(
                Rectangle()
                    .fill(backgroundColor)
            )
            .cornerRadius(cornerRadius)
            .shadow(radius: 5)
    }
}

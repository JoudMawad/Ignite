import SwiftUI

// MARK: - Custom Transition for Alerts

struct BlurTransitionModifier: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        content.blur(radius: active ? 30 : 0)
    }
}

extension AnyTransition {
    static var blurScale: AnyTransition {
        AnyTransition.modifier(
            active: BlurTransitionModifier(active: true),
            identity: BlurTransitionModifier(active: false)
        ).combined(with: .scale)
    }
}

// MARK: - Reusable Custom Alert Overlay

struct CustomAlertOverlay: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onDismiss()
                    }
                }
            CustomAlert(
                title: title,
                message: message,
                onDismiss: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onDismiss()
                    }
                }
            )
            .transition(.blurScale)
            .zIndex(1)
        }
    }
}

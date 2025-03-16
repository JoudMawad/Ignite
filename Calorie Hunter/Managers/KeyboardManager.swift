import Foundation
import SwiftUI


final class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation(.easeOut(duration: 0.3)) {
                keyboardHeight = frame.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        withAnimation(.easeOut(duration: 0.3)) {
            keyboardHeight = 0
        }
    }
}

import SwiftUI
import UIKit

// A SwiftUI wrapper that allows using a UIKit view controller as a SwiftUI view.
// This struct conforms to UIViewControllerRepresentable, which bridges UIKit view controllers to SwiftUI.
struct SplashView: UIViewControllerRepresentable {
    
    // Creates and returns an instance of AppSplashViewController.
    // This is called once when the SwiftUI view hierarchy first creates the view controller.
    func makeUIViewController(context: Context) -> AppSplashViewController {
        return AppSplashViewController()
    }
    
    // Updates the state of the view controller based on new SwiftUI state.
    // In this case, no updates are needed after the view controller is created.
    func updateUIViewController(_ uiViewController: AppSplashViewController, context: Context) {
        // No dynamic updates needed.
    }
}

// SwiftUI preview provider to render a preview of SplashView in Xcode.
// It is set to display in portrait orientation.
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .previewInterfaceOrientation(.portrait)
    }
}

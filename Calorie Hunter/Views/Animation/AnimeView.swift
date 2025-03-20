import SwiftUI
import UIKit

struct SplashView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AppSplashViewController {
        return AppSplashViewController()
    }
    
    func updateUIViewController(_ uiViewController: AppSplashViewController, context: Context) {
        // No dynamic updates needed.
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .previewInterfaceOrientation(.portrait)
    }
}

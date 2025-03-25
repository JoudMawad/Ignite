import UIKit
import WebKit

// A view controller that displays a splash screen with a web-based animation.
class SplashViewController: UIViewController {
    // The WKWebView that will display the HTML content (with SVG animation).
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and set up the WKWebView to cover the entire view.
        webView = WKWebView(frame: self.view.bounds)
        webView.backgroundColor = .clear  // Ensure the background is transparent.
        webView.isOpaque = false          // Allows transparency by setting opacity to false.
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Adjust size on rotation.
        self.view.addSubview(webView)     // Add the webView as a subview.

        // Load the local HTML file that contains the SVG animation.
        if let filePath = Bundle.main.path(forResource: "FireAnimation", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            // Allow read access to the directory containing the HTML file.
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    // Called after the view has appeared on screen.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add a small delay (1.5 seconds) before transitioning to the main UI.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showMainApp()  // Transition to the main app view controller.
        }
    }

    // Transition to the main part of the app.
    func showMainApp() {
        // Instantiate the main view controller from the storyboard.
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") {
            // Set up a cross-dissolve transition for a smooth effect.
            mainVC.modalTransitionStyle = .crossDissolve
            mainVC.modalPresentationStyle = .fullScreen
            // Present the main view controller.
            self.present(mainVC, animated: true, completion: nil)
        }
    }
}

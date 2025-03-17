import UIKit
import WebKit

class SplashViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the WKWebView to fill the view.
        webView = WKWebView(frame: self.view.bounds)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)

        // Load the HTML file containing the SVG animation.
        if let filePath = Bundle.main.path(forResource: "FireAnimation", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Delay before transitioning to the main UI.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showMainApp()
        }
    }

    func showMainApp() {
        // Transition to your main app view controller.
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") {
            mainVC.modalTransitionStyle = .crossDissolve
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        }
    }
}

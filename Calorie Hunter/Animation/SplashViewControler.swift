import UIKit
import WebKit

class SplashViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the WKWebView to fill the view.
        webView = WKWebView(frame: self.view.bounds)
        // (Optional) Temporarily set a background color to debug visibility.
        // webView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)
        print("SplashViewController: viewDidLoad - WKWebView added.")

        // Load the HTML file containing the SVG animation.
        if let filePath = Bundle.main.path(forResource: "FireAnimation", ofType: "html") {
            print("Found FireAnimation.html at: \(filePath)")
            let fileURL = URL(fileURLWithPath: filePath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else {
            print("FireAnimation.html not found in bundle!")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SplashViewController: viewDidAppear")
        // Delay before transitioning to the main UI.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showMainApp()
        }
    }

    func showMainApp() {
        // Transition to your main app view controller.
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") {
            print("Transitioning to MainViewController")
            mainVC.modalTransitionStyle = .crossDissolve
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        } else {
            print("MainViewController not found in storyboard!")
        }
    }
}

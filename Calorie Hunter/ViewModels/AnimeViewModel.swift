import UIKit
import WebKit

class AppSplashViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the background to the system's background color (white in light mode, black in dark mode)
        self.view.backgroundColor = UIColor.systemBackground

        // Define a fixed size for the WKWebView (adjust as needed)
        let webViewSize: CGFloat = 300
        // Center the web view within the parent view
        let frame = CGRect(
            x: (self.view.bounds.width - webViewSize) / 3.2,
            y: (self.view.bounds.height - webViewSize) / 2,
            width: webViewSize,
            height: webViewSize
        )
        webView = WKWebView(frame: frame)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        // Use flexible margins so it remains centered on rotation or different screen sizes.
        webView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        self.view.addSubview(webView)

        // Load the HTML file containing your SVG animation.
        if let filePath = Bundle.main.path(forResource: "FireAnimation", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } 
    }
}

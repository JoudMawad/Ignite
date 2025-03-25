import UIKit
import WebKit

// AppSplashViewController displays a splash screen with a web-based SVG animation.
// It sets up a WKWebView in the center of the screen to load and display an HTML file.
class AppSplashViewController: UIViewController {
    // The web view used to display the SVG animation.
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's background color to the system default,
        // which adapts to light (white) or dark (black) mode.
        self.view.backgroundColor = UIColor.systemBackground

        // Define a fixed size for the WKWebView (adjust as needed).
        let webViewSize: CGFloat = 300
        
        // Calculate the frame to center the web view within the parent view.
        // The x-offset is adjusted by dividing by 3.2 for a custom horizontal position.
        let frame = CGRect(
            x: (self.view.bounds.width - webViewSize) / 3.2,
            y: (self.view.bounds.height - webViewSize) / 2,
            width: webViewSize,
            height: webViewSize
        )
        
        // Initialize the WKWebView with the calculated frame.
        webView = WKWebView(frame: frame)
        // Set the web view's background to clear so the underlying view color shows through.
        webView.backgroundColor = .clear
        // Allow transparency by setting the opacity to false.
        webView.isOpaque = false
        // Use flexible margins so the web view remains centered on rotation or different screen sizes.
        webView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        // Add the web view as a subview.
        self.view.addSubview(webView)

        // Load the HTML file that contains the SVG animation.
        if let filePath = Bundle.main.path(forResource: "FireAnimation", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            // Load the local HTML file into the web view,
            // allowing read access to its directory.
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }
}

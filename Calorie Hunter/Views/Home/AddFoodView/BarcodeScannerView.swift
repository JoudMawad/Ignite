import SwiftUI
import AVFoundation

/// A SwiftUI wrapper around ScannerViewController to scan barcodes.
struct BarcodeScannerView: UIViewControllerRepresentable {
    /// Called when a barcode is successfully scanned.
    var completion: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        // Instantiate the UIKit scanner from the separate file
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No dynamic updates needed
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: BarcodeScannerView
        init(parent: BarcodeScannerView) { self.parent = parent }
        func didFind(code: String) {
            parent.completion(code)
        }
    }
}

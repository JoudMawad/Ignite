import UIKit
import AVFoundation

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Public
    weak var delegate: ScannerViewControllerDelegate?
    
    // MARK: - Private
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private lazy var feedback = UIImpactFeedbackGenerator(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupCamera()
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Safely layout previewLayer if available
        previewLayer?.frame = view.bounds
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        //--------------------------------------------------
        // 1.  Get the camera and add it to the session
        //--------------------------------------------------
        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device)
        else {                      // running in the Simulator / SwiftUI preview
                    // your helper that shows a black layer
            return
        }

        session.addInput(input)

        //--------------------------------------------------
        // 2.  🔍  OPTICAL ZOOM  &  continuous autofocus
        //--------------------------------------------------
        do {
            try device.lockForConfiguration()

            let desiredZoom: CGFloat = 2.0                 // 2× zoom
            device.videoZoomFactor = min(
                desiredZoom,
                device.activeFormat.videoMaxZoomFactor     // never exceed hardware max
            )

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5) // centre
            }

            device.unlockForConfiguration()
        } catch {
            print("⚠️ Cannot lock camera for zoom/focus: \(error)")
        }

        //--------------------------------------------------
        // 3.  Metadata output (barcode detection)
        //--------------------------------------------------
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .pdf417]

        //--------------------------------------------------
        // 4.  Preview layer
        //--------------------------------------------------
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        previewLayer = layer
    }

    
    // MARK: - Delegate Callback
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection)
    {
        guard let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let string = first.stringValue,
              let barObject = previewLayer?.transformedMetadataObject(for: first)
        else { return }
        
        let box = UIView(frame: barObject.bounds)
        box.layer.borderColor = UIColor.systemGreen.cgColor
        box.layer.borderWidth = 2
        view.addSubview(box)
        
        feedback.impactOccurred()
        session.stopRunning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.didFind(code: string)
        }
    }
}

#if DEBUG
import SwiftUI

/// SwiftUI Preview wrapper for ScannerViewController
struct ScannerViewController_Preview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController()
    }
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

@available(iOS 13.0, *)
struct ScannerViewController_Previews: PreviewProvider {
    static var previews: some View {
        ScannerViewController_Preview()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif

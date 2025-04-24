import SwiftUI
import VisionKit
import Vision

struct NutritionCaptureView: UIViewControllerRepresentable {
    // values we will send back
    var onExtracted: (NutritionFacts) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_: VNDocumentCameraViewController, context: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let parent: NutritionCaptureView
        init(_ parent: NutritionCaptureView) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else { controller.dismiss(animated: true); return }

            // The user usually takes exactly one photo; use page 0
            let image = scan.imageOfPage(at: 0)
            recogniseText(in: image) { facts in
                DispatchQueue.main.async {
                    self.parent.onExtracted(facts)
                    controller.dismiss(animated: true)
                }
            }
        }

        private func recogniseText(in image: UIImage,
                                   completion: @escaping (NutritionFacts) -> Void) {

            let request = VNRecognizeTextRequest { req, _ in
                let observations = req.results as? [VNRecognizedTextObservation] ?? []
                let fullText = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                let facts = NutritionFacts(from: fullText, debug: true)

                        completion(facts)            // send the parsed macros back
                completion( NutritionFacts(from: fullText) )
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true      // helps with OCR errors

            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
                try? handler.perform([request])
            }
        }
    }
}

import SwiftUI
import UIKit
import CoreData

// MARK: - ImagePicker Implementation

/// A SwiftUI wrapper for UIImagePickerController to allow image selection in SwiftUI.
struct ImagePicker: UIViewControllerRepresentable {
    // Binding to hold the selected image.
    @Binding var image: UIImage?
    // Environment variable to dismiss the image picker.
    @Environment(\.presentationMode) private var presentationMode

    /// Coordinator class to manage UIImagePickerController delegate methods.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        // Reference to the parent ImagePicker instance.
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when the user finishes picking an image.
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Attempt to retrieve the edited image first.
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            }
            // If there's no edited image, use the original image.
            else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            // Dismiss the image picker.
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Called when the user cancels the image picking.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Dismiss the image picker.
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    // Creates the coordinator instance to handle delegate methods.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates and configures the UIImagePickerController.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Set the coordinator as the delegate.
        picker.delegate = context.coordinator
        // Allow editing of the selected image.
        picker.allowsEditing = true
        return picker
    }

    // Update method; no dynamic updates needed for this simple picker.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
}

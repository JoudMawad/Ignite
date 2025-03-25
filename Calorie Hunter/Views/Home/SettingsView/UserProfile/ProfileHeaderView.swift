import SwiftUI

/// A view that displays a user's profile image or a default placeholder.
/// The view listens to changes in the image view model and shows an image picker when needed.
struct ProfileHeaderView: View {
    // MARK: - Properties
    
    /// The view model that handles the profile image fetching and updating.
    @ObservedObject var imageVM: ProfileImageViewModel
    
    /// A binding that controls the visibility of the image picker.
    @Binding var isShowingImagePicker: Bool
    
    // MARK: - Body
    
    var body: some View {
        // GeometryReader allows the view to adapt to the available space.
        GeometryReader { geometry in
            // ZStack overlays the content, aligning its children at the bottom trailing corner.
            ZStack(alignment: .bottomTrailing) {
                // If a profile image is available from the view model, display it.
                if let profileImage = imageVM.profileImage {
                    Image(uiImage: profileImage)
                        .resizable() // Makes the image resizable.
                        .aspectRatio(contentMode: .fill) // Ensures the image fills its frame, preserving its aspect ratio.
                        .frame(width: geometry.size.width, height: geometry.size.height) // Uses the full available width and height.
                        .clipped() // Clips the image to avoid overflow.
                } else {
                    // If no profile image exists, show a default system placeholder.
                    Image(systemName: "person.crop.circle.fill")
                        .resizable() // Makes the system image resizable.
                        .aspectRatio(contentMode: .fill) // Ensures the image fills its frame, preserving its aspect ratio.
                        .frame(width: geometry.size.width, height: geometry.size.height) // Uses the full available width and height.
                        // Sets the foreground color to a semi-transparent gray for a subtle look.
                        .foregroundColor(.gray.opacity(0.3))
                        .clipped() // Clips the image to avoid overflow.
                }
            }
        }
    }
}

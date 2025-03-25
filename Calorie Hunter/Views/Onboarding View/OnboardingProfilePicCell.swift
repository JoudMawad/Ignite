import SwiftUI

/// A reusable onboarding cell that displays a profile picture.
/// If a profile image is set, it displays the image; otherwise, it shows a default placeholder icon.
/// Tapping the cell toggles the image picker to allow the user to choose a new profile picture.
struct OnboardingProfilePicCell: View {
    // MARK: - Input Properties
    
    /// The title text displayed above the profile picture.
    var title: String = "Profile Picture"
    
    /// The system image name for the placeholder icon.
    var systemImageName: String = "person.crop.circle.fill"
    
    /// Binding to a boolean that toggles the display of an image picker.
    @Binding var isShowingImagePicker: Bool
    
    /// Binding to the optional UIImage representing the user's profile picture.
    @Binding var profileImage: UIImage?

    // MARK: - Environment
    
    /// Provides the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            // Display the title text above the image.
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)

            // ZStack to overlay the image or placeholder icon.
            ZStack {
                if let image = profileImage {
                    // Display the selected profile image.
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)  // Fills the frame while maintaining aspect ratio.
                        .frame(width: 201, height: 108)    // Explicit frame matching the cell's dimensions.
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(y: -14.7) // Adjusts vertical positioning for better visual balance.
                } else {
                    // Display a placeholder system icon if no image is available.
                    Image(systemName: systemImageName)
                        .font(.system(size: 50))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.vertical, 10)
        }
        .frame(width: 200, height: 105)
        .background(
            // Background with rounded corners and a subtle shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        .contentShape(Rectangle()) // Ensures the entire cell area is tappable.
        .onTapGesture {
            // Log tap event and toggle the image picker.
            print("Profile cell tapped")
            isShowingImagePicker = true
        }
    }
}

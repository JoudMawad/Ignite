import SwiftUI

struct OnboardingProfilePicCell: View {
    var title: String = "Profile Picture"
    var systemImageName: String = "person.crop.circle.fill" // placeholder icon
    @Binding var isShowingImagePicker: Bool
    @Binding var profileImage: UIImage? // Bound profile image

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)

            // Image display: show selected image if available, else placeholder icon.
            ZStack {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)  // Fill the frame
                        .frame(width: 201, height: 108)    // Match the cell's frame
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(y:-14.7)// Clip to the same shape
                
                        
                } else {
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
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        .contentShape(Rectangle()) // Makes the entire cell tappable
        .onTapGesture {
            print("Profile cell tapped")
            isShowingImagePicker = true
        }
    }
}

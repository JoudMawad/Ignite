import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var imageVM: ProfileImageViewModel
    @Binding var isShowingImagePicker: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                if let profileImage = imageVM.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(.gray.opacity(0.3))
                        .clipped()
                }

            }
        }
    }
}

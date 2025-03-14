import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel
    @StateObject var imageVM = ProfileImageViewModel()
    @State private var isShowingImagePicker = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ZStack(alignment: .top) {
                        ProfileHeaderView(imageVM: imageVM, isShowingImagePicker: $isShowingImagePicker)
                            .frame(height: geometry.size.height * 0.6)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.3)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )

                        ScrollView(showsIndicators: false) {
                                FormContainerView(viewModel: viewModel, isShowingImagePicker: $isShowingImagePicker)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $imageVM.profileImage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: UserProfileViewModel())
    }
}

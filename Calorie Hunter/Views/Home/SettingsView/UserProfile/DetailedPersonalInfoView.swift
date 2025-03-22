import SwiftUI

struct DetailedPersonalInfoView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingImagePicker: Bool

    var body: some View {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                VStack() {
                    PersonalInfoSectionView(viewModel: viewModel, isShowingImagePicker: $isShowingImagePicker)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            
            .onTapGesture {
                hideKeyboard()
            }
        }
}

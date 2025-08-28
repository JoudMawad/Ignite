import SwiftUI

/// A view that displays a user's profile screen with a header image and an editable form.
/// It includes image picking functionality and a back button to dismiss the view.
struct UserProfileView: View {
    // MARK: - Environment Properties
    
    /// Dismisses the current view when called.
    @Environment(\.dismiss) var dismiss
    
    /// Accesses the current color scheme (dark or light) for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Observed and State Objects
    
    /// View model that handles user profile data and business logic.
    @ObservedObject var viewModel: UserProfileViewModel
    
    @ObservedObject var goalsViewModel: GoalsViewModel
    
    /// View model that handles profile image logic (e.g., loading and updating the image).
    @StateObject var imageVM = ProfileImageViewModel()
    
    /// Controls whether the image picker sheet is displayed.
    @State private var isShowingImagePicker = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                // ZStack layers the header and the form, allowing for overlapping elements.
                ZStack {
                    // Nested ZStack to position the header at the top and overlay the form.
                    ZStack(alignment: .top) {
                        // ProfileHeaderView displays the user's profile image or a placeholder.
                        ProfileHeaderView(imageVM: imageVM, isShowingImagePicker: $isShowingImagePicker)
                            .frame(height: geometry.size.height * 0.7) // Header occupies 70% of the screen height.
                            .clipped() // Prevents content from overflowing its bounds.
                            .overlay(
                                // Adds a gradient overlay for improved readability of any overlaying text or elements.
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.3)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                        
                        // ScrollView contains the form for user profile details.
                        ScrollView(showsIndicators: false) {
                            // FormContainerView handles the detailed user input fields.
                            FormContainerView(viewModel: viewModel, goalsViewModel: goalsViewModel, isShowingImagePicker: $isShowingImagePicker)
                        }
                        // Tapping anywhere within the ScrollView dismisses the keyboard.
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                    }
                    // Ignore safe area at the top to allow the header image to extend fully.
                    .edgesIgnoringSafeArea(.top)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            // Background color adapts to the current color scheme.
            .background(colorScheme == .dark ? Color.black : Color.white)
            // Sets the navigation title to be displayed inline.
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Toolbar item for the leading (left-side) navigation bar button.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Dismiss the current view when the back button is tapped.
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
            }
            // Presents the image picker as a modal sheet when triggered.
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $imageVM.profileImage)
            }
        }
        // Ensures a consistent navigation style across different devices.
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

/// A preview provider for UserProfileView to enable live previews in Xcode.
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: UserProfileViewModel(), goalsViewModel: GoalsViewModel())
    }
}

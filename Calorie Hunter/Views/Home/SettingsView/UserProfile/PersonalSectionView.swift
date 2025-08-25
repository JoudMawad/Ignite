import SwiftUI

// A reusable view that applies a fade and slight move-up animation on appearance.
struct AnimatedCard<Content: View>: View {
    @State private var isVisible = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.5), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct PersonalInfoSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var isShowingImagePicker: Bool
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var imageVM = ProfileImageViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AnimatedCard {
                    Text("Personal Information")
                        .font(.largeTitle)
                        .bold()
                }
                HStack {
                    
                    
                    AnimatedCard {
                        OnboardingProfilePicCell(
                            isShowingImagePicker: $isShowingImagePicker,
                            profileImage: $imageVM.profileImage
                        )
                    }
                    
                    AnimatedCard {
                        OnboardingInputCellString(
                            title: "Name",
                            placeholder: viewModel.name,
                            systemImageName: "person.fill",
                            value: $viewModel.name
                        )
                    }
                }
                
                HStack {
                    
                    AnimatedCard {
                        OnboardingInputCellDouble(
                            title: "Weight (kg)",
                            placeholder: String(viewModel.currentWeight),
                            systemImageName: "scalemass",
                            value: $viewModel.currentWeight
                        )
                    }
                    
                    
                    
                    AnimatedCard {
                        OnboardingInputCellInt(
                            title: "Height (cm)",
                            placeholder: String(viewModel.height),
                            systemImageName: "ruler.fill",
                            value: $viewModel.height
                        )
                    }
                }
                
                HStack {
                    
                    AnimatedCard {
                        OnboardingInputCellInt(
                            title: "Age",
                            placeholder: String(viewModel.age),
                            systemImageName: "number.circle",
                            value: $viewModel.age
                        )
                    }
                    
                    
                    
                    AnimatedCard {
                        OnboardingInputCellPicker(
                            title: "Gender",
                            systemImageName: "person.2.fill",
                            options: ["Male", "Female", "Other"],
                            selection: $viewModel.gender
                        )
                    }
                }
            }
            .padding(.top, -40)
            
        }
    }
}

struct PersonalInfoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PersonalInfoSectionView(
                viewModel: UserProfileViewModel(),
                isShowingImagePicker: .constant(false)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)

            PersonalInfoSectionView(
                viewModel: UserProfileViewModel(),
                isShowingImagePicker: .constant(false)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}

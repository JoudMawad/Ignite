import SwiftUI

struct PersonalInfoSectionView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var isShowingImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                OnboardingInputCellString(
                    title: "Name",
                    placeholder: viewModel.name,
                    systemImageName: "person.fill",
                    value: $viewModel.name
                )

                
                OnboardingInputCellInt(
                    title: "Age",
                    placeholder: String(viewModel.age),
                    systemImageName: "number.circle",
                    value: $viewModel.age
                )
            }
            
            HStack {
                OnboardingInputCellInt(
                    title: "Height (cm)",
                    placeholder: String(viewModel.height),
                    systemImageName: "ruler.fill",
                    value: $viewModel.height
                )
                OnboardingInputCellDouble(
                    title: "Weight (kg)",
                    placeholder:String(viewModel.currentWeight),
                    systemImageName: "scalemass",
                    value: $viewModel.currentWeight
                )
            }
            
            OnboardingInputCellPicker(
                title: "Gender",
                systemImageName: "person.2.fill",
                options: ["Male", "Female", "Other"],
                selection: $viewModel.gender
            )
            
            Button(action: {
                isShowingImagePicker = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
            }
        }
    }
}



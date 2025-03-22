import SwiftUI

struct DetailedHealthGoalsView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            VStack() {
                
                HealthGoalsSectionView(viewModel: viewModel)
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

import SwiftUI

struct DetailedHealthGoalsView: View {
    @ObservedObject var goalsViewModel: GoalsViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            VStack() {
                
                HealthGoalsSectionView(goalsViewModel: goalsViewModel, userprofileviewModel: userProfileViewModel)
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

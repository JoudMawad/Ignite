import SwiftUI

struct FormContainerView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingImagePicker: Bool
    
    // Computed properties for first and last name.
    var firstName: String {
        let parts = viewModel.name.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    var lastName: String {
        let parts = viewModel.name.split(separator: " ")
        return parts.dropFirst().joined(separator: " ")
    }
    
    // Example calorie manager.
    private let calorieManager = CalorieHistoryManager()
    
    var totalCaloriesTracked: Int {
        let period = calorieManager.totalCaloriesForPeriod(days: 3000)
        return period.reduce(0) { $0 + $1.calories }
    }
    
    var goalAchievementPercentage: Double {
        let startWeight = viewModel.startWeight
        let goalWeight = viewModel.goalWeight
        let currentWeight = viewModel.currentWeight
        let totalChangeNeeded = startWeight - goalWeight
        if totalChangeNeeded == 0 { return 0 }
        let changeAchieved = startWeight - currentWeight
        return (changeAchieved / totalChangeNeeded) * 100
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack() {
                Spacer().frame(height: 390) // Adjust as needed for vertical spacing
                
                // User name and stats area.
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(firstName)
                            .font(.system(size: 45, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        if !lastName.isEmpty {
                            Text(lastName)
                                .font(.system(size: 45, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                                .padding(.leading, 10)
                                .padding(.top, -10)
                        }
                        
                        HStack(spacing: 16) {
                            StatView(title: "Calories Tracked", value: "\(totalCaloriesTracked) cal")
                            StatView(title: "Progress", value: String(format: "%.0f%%", goalAchievementPercentage))
                        }
                        .padding(.vertical, 20)
                    }
                    .padding()
                    
                    WeightProgressView(viewModel: viewModel, onWeightChange: { })
                        .padding(.top, -40)
                        .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Personal Information Section.
                    SectionHeaderView(title: "Personal Information")
                    PersonalInfoSectionView(viewModel: viewModel, isShowingImagePicker: $isShowingImagePicker)
                    
                    Divider().padding(.horizontal)
                    
                    // Health Goals Section.
                    SectionHeaderView(title: "Health Goals")
                    HealthGoalsSectionView(viewModel: viewModel)
                    
                    Spacer(minLength: 40)
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.8), radius: 30, x: 0, y: 0)
            }
        }
    }
}


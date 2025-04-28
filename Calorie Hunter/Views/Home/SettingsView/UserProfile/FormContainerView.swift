import SwiftUI

struct FormContainerView: View {
    // ViewModel holding user profile data.
    @ObservedObject var viewModel: UserProfileViewModel
    // Adapt UI styling based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    // Binding to control the presentation of an image picker.
    @Binding var isShowingImagePicker: Bool
    
    // MARK: - Computed Properties for Name
    /// Extracts the first name from the full name.
    var firstName: String {
        let parts = viewModel.name.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    /// Extracts the last name (all parts except the first) from the full name.
    var lastName: String {
        let parts = viewModel.name.split(separator: " ")
        return parts.dropFirst().joined(separator: " ")
    }
    
    // MARK: - Example Calorie Manager Usage
    /// An example instance of CalorieHistoryManager to track calories.
    private let calorieManager = CalorieHistoryManager()
    
    /// Computes the total calories tracked over a long period (3000 days).
    var totalCaloriesTracked: Int {
      calorieManager.totalLifetimeCalories()
    }
    
    // MARK: - Weight Goal Achievement Calculation
    /// Computes the percentage of weight goal achieved based on start, current, and goal weights.
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
            VStack {
                // Spacer to create vertical space at the top of the scroll view.
                Spacer().frame(height: 390) // Adjust as needed for vertical spacing
                
                VStack(spacing: 26) {
                    // MARK: - User Name and Stats Area
                    VStack(alignment: .leading, spacing: 0) {
                        // Display the user's first name in large bold text.
                        Text(firstName)
                            .font(.system(size: 45, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        // Display the last name if available, with a slight offset.
                        if !lastName.isEmpty {
                            Text(lastName)
                                .font(.system(size: 45, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                                .padding(.leading, 10)
                                .padding(.top, -10)
                        }
                        
                        // Display key stats such as total calories tracked and weight progress.
                        HStack(spacing: 16) {
                            StatView(title: "Calories Tracked", value: "\(totalCaloriesTracked) cal")
                            StatView(title: "Progress", value: String(format: "%.0f%%", goalAchievementPercentage))
                        }
                        .padding(.vertical, 20)
                    }
                    .padding()
                    
                    // MARK: - Weight Progress Indicator
                    WeightProgressView(viewModel: viewModel, onWeightChange: { })
                        .padding(.top, -40)
                        .padding(.horizontal)
                    
                    // MARK: - Navigation Links to Detailed Views
                    VStack(spacing: -20){
                        // Personal Information Section as a tappable NavigationLink.
                        NavigationLink(
                            destination: DetailedPersonalInfoView(viewModel: viewModel, isShowingImagePicker: $isShowingImagePicker)
                        ){
                            HStack {
                                Spacer()
                                Text("Profile Info")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.primary)
                                Spacer()
                            }
                            .frame(width: 390, height: 100)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Health Goals Section as a tappable NavigationLink.
                        NavigationLink(
                            destination: DetailedHealthGoalsView(viewModel: viewModel)
                        ) {
                            HStack {
                                Spacer()
                                Text("Health Goals")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.primary)
                                Spacer()
                            }
                            .frame(width: 380, height: 100)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer(minLength: 40)
                }
                // Set the background color and apply rounded corners only to the top edges.
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                // Apply a shadow to create depth.
                .shadow(color: Color.black.opacity(0.8), radius: 30, x: 0, y: 0)
            }
        }
    }
}

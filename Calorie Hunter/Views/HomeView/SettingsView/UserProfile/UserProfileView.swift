import SwiftUI

// MARK: - UserProfileView
struct UserProfileView: View {
    // Environment & Observed properties.
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: UserProfileViewModel
    @StateObject var imageVM = ProfileImageViewModel()
    @State private var isShowingImagePicker = false
    
    // Extract first and last names from the Core Data–backed profile.
    var firstName: String {
        let fullName = viewModel.name
        let parts = fullName.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    var lastName: String {
        let fullName = viewModel.name
        let parts = fullName.split(separator: " ")
        return parts.dropFirst().joined(separator: " ")
    }
    
    // CalorieHistoryManager instance.
    private let calorieManager = CalorieHistoryManager()
    
    // Total Calories tracked over a period.
    private var totalCaloriesTracked: Int {
        let period = calorieManager.totalCaloriesForPeriod(days: 3000)
        return period.reduce(0) { $0 + $1.calories }
    }
    
    // Goal Achievement Percentage calculation.
    private var goalAchievementPercentage: Double {
        let startWeight = viewModel.startWeight
        let goalWeight = viewModel.goalWeight
        let currentWeight = viewModel.currentWeight
        let totalChangeNeeded = startWeight - goalWeight
        if totalChangeNeeded == 0 { return 0 }
        let changeAchieved = startWeight - currentWeight
        return (changeAchieved / totalChangeNeeded) * 100
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Profile header with background image.
                    profileHeader
                        .frame(height: geometry.size.height * 0.6)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.3)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                    
                    // Scrollable form container overlapping the header.
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer().frame(height: geometry.size.height * 0.55)
                            formContainer
                        }
                    }
                    .frame(maxWidth: 600)
                    .padding(.horizontal, 14)
                }
                .edgesIgnoringSafeArea(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Back button.
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
    }
    
    // MARK: - Profile Header (Photo Background)
    private var profileHeader: some View {
        ZStack(alignment: .bottomTrailing) {
            if let profileImage = imageVM.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray.opacity(0.3))
            }
            Button(action: {
                isShowingImagePicker = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
            }
            .padding(10)
        }
    }
    
    // MARK: - Form Container (Scrollable List of Inputs)
    private var formContainer: some View {
        VStack(spacing: 16) {
            // Top area: User name and stats row.
            VStack(alignment: .leading, spacing: 0) {
                Text(firstName)
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                if !lastName.isEmpty {
                    Text(lastName)
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.leading, 10)
                        .padding(.top, -10)
                }
                
                // Stats row.
                HStack(spacing: 16) {
                    statView(title: "Calories Tracked", value: "\(totalCaloriesTracked) cal")
                    statView(title: "Progress", value: String(format: "%.0f%%", goalAchievementPercentage))
                }
                .padding(.bottom, 5)
                .padding(.top, 20)
            }
            .padding()
            
            // Weight progress view.
            WeightProgressView(
                viewModel: viewModel,
                onWeightChange: { }
            )
            .padding(.top, -10)
            
            Divider().padding(.horizontal)
            
            // Personal Information Section.
            sectionHeader("Personal Information")
            personalInfoSection
            
            Divider().padding(.horizontal)
            
            // Health Goals Section.
            sectionHeader("Health Goals")
            healthGoalsSection
            
            Spacer(minLength: 40)
        }
        .padding(.bottom, 20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.8), radius: 30, x: 0, y: 0)
    }
    
    // MARK: - Reusable Stat View
    private func statView(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Section Header (Reusable)
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Personal Information Section
    private var personalInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    // Name field.
                    TextField("Enter name", text: Binding(
                        get: { viewModel.name },
                        set: { newValue in
                            viewModel.name = newValue
                        }
                    ))
                    .font(.system(size: 19, weight: .semibold, design: .default))
                    
                    // Age field.
                    TextField("Age", text: Binding<String>(
                        get: { "\(viewModel.age)" },
                        set: { newValue in
                            if let intValue = Int(newValue) {
                                viewModel.age = intValue
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .frame(width: 80)




                    
                    // Height field.
                    HStack {
                        Text("Height:")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        TextField("", value: Binding(
                            get: { viewModel.height },
                            set: { newValue in
                                viewModel.height = newValue
                            }
                        ), format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .frame(width: 80)
                    }
                    
                    // Weight field.
                    HStack {
                        Text("Weight:")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        TextField("", value: Binding(
                            get: { viewModel.currentWeight },
                            set: { newValue in
                                viewModel.currentWeight = newValue
                            }
                        ), format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .frame(width: 80)
                    }
                    
                    // Button to update profile image.
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .background(Color.white.clipShape(Circle()))
                    }
                    .padding(10)
                }
                VStack {
                    // Gender field.
                    Text("Gender")
                        .font(.system(size: 19, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    Picker("", selection: Binding(
                        get: { viewModel.gender },
                        set: { newValue in
                            viewModel.gender = newValue
                        }
                    )) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 180)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Health Goals Section
    private var healthGoalsSection: some View {
        VStack(spacing: 12) {
            // Start Weight field.
            HStack {
                Text("Start Weight:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: Binding(
                    get: { viewModel.startWeight },
                    set: { newValue in
                        viewModel.startWeight = newValue
                    }
                ), format: .number.precision(.fractionLength(1)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .frame(width: 80)
            }
            // Goal Weight field.
            HStack {
                Text("Goal Weight:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: Binding(
                    get: { viewModel.goalWeight },
                    set: { newValue in
                        viewModel.goalWeight = newValue
                    }
                ), format: .number.precision(.fractionLength(1)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .frame(width: 80)
            }
            // Calorie Goal field.
            HStack {
                Text("Calorie Goal:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: Binding(
                    get: { viewModel.dailyCalorieGoal },
                    set: { newValue in
                        viewModel.dailyCalorieGoal = newValue
                    }
                ), format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .frame(width: 80)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Rounded Corner Modifier for Specific Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
        
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: UserProfileViewModel())
    }
}

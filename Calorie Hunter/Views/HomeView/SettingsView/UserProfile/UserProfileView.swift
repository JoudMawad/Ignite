//
//  UserProfileView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 12.03.25.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    // Environment & Observed properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: UserProfileViewModel
    @StateObject var imageVM = ProfileImageViewModel()
    @StateObject var userProfileVM = UserProfileViewModel()
    @State private var isShowingImagePicker = false
    
    // Compute firstName and lastName from viewModel.name.
    var firstName: String {
        let parts = viewModel.name.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    var lastName: String {
        let parts = viewModel.name.split(separator: " ")
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
        let totalChangeNeeded = viewModel.startWeight - viewModel.goalWeight
        if totalChangeNeeded == 0 { return 0 }
        let changeAchieved = viewModel.startWeight - viewModel.currentWeight
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
                startWeight: userProfileVM.startWeight,
                viewModel: userProfileVM,
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
    
    // MARK: - Reusable Stat View for the Stats Row
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
                    TextField("Enter name", text: $viewModel.name)
                        .onChange(of: viewModel.name) { _, _ in viewModel.saveProfile() }
                        .font(.system(size: 19, weight: .semibold, design: .default))
                    
                    // Age field (Int).
                    HStack {
                        Text("Age:")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        TextField("", value: $viewModel.age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .frame(width: 80)
                            .onSubmit { viewModel.saveProfile() }
                    }
                    
                    // Height field (Int).
                    HStack {
                        Text("Height:")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        TextField("", value: $viewModel.height, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .frame(width: 80)
                            .onSubmit { viewModel.saveProfile() }
                    }
                    
                    // Weight field (Double) with one decimal precision.
                    HStack {
                        Text("Weight:")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        TextField("", value: $viewModel.currentWeight, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .frame(width: 80)
                            .onSubmit { viewModel.saveProfile() }
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
                    // Gender field using a segmented picker.
                    Text("Gender")
                        .font(.system(size: 19, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    Picker("", selection: $viewModel.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 180)
                    .onChange(of: viewModel.gender) { _, _ in viewModel.saveProfile() }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Health Goals Section
    private var healthGoalsSection: some View {
        VStack(spacing: 12) {
            // Start Weight field (Double).
            HStack {
                Text("Start Weight:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: $viewModel.startWeight, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .frame(width: 80)
                    .onSubmit { viewModel.saveProfile() }
            }
            // Goal Weight field (Double).
            HStack {
                Text("Goal Weight:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: $viewModel.goalWeight, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .frame(width: 80)
                    .onSubmit { viewModel.saveProfile() }
            }
            // Calorie Goal field (Int).
            HStack {
                Text("Calorie Goal:")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                TextField("", value: $viewModel.dailyCalorieGoal, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .frame(width: 80)
                    .onSubmit { viewModel.saveProfile() }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Rounded Corner Modifier for Specific Corners
extension View {
    /// Applies a corner radius to specified corners.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

/// Shape that rounds only specified corners.
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

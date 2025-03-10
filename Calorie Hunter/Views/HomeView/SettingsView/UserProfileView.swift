import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @StateObject var imageVM = ProfileImageViewModel()
    @State private var isShowingImagePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Section: Profile image with name displayed under it.
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        if let profileImage = imageVM.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(color: Color.cyan.opacity(0.7), radius: 5, x: 0, y: 0)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(color: Color.cyan.opacity(0.7), radius: 5, x: 0, y: 0)
                        }
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: -8, y: -8)
                    }
                    
                    // Display the name (read-only) under the profile image.
                    Text(viewModel.name)
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                }
                .padding(.top, 40)
                
                // Personal Information Section:
                VStack(spacing: 12) {
                    // Editable Name field.
                    CustomTextField(title: "Name:", value: $viewModel.name, onCommit: {
                        viewModel.saveProfile()
                    })
                    
                    // Age field: using conversion Binding for numeric values.
                    CustomTextField(
                        title: "Age:",
                        value: Binding<Double>(
                            get: { Double(viewModel.age) },
                            set: { viewModel.age = Int($0) }
                        ),
                        onCommit: {
                            viewModel.saveProfile()
                        }
                    )
                    
                    // Height field:
                    CustomTextField(
                        title: "Height:",
                        value: Binding<Double>(
                            get: { Double(viewModel.height) },
                            set: { viewModel.height = Int($0) }
                        ),
                        onCommit: {
                            viewModel.saveProfile()
                        }
                    )
                    
                    // Gender Picker.
                    HStack {
                        Text("Gender")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Picker("", selection: $viewModel.gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 180)
                        .onChange(of: viewModel.gender) { newGender, oldGender in
                            viewModel.saveProfile()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                }
                .background(Color.black)
                .padding(.top, 35)
                .padding(.horizontal, 60)
                .padding(.bottom, 100)
                .background(
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color(UIColor.black))
                        .shadow(color: Color.cyan.opacity(0.3), radius: 14, x: 0, y: 10)
                        .padding(.horizontal, 30)
                )
                
                Spacer()
                
                // Health Goal Fields Section.
                VStack(spacing: 8) {
                    CustomTextField(title: "Start Weight:", value: $viewModel.startWeight, onCommit: {
                        viewModel.saveProfile()
                    })
                    CustomTextField(title: "Current Weight:", value: $viewModel.currentWeight, onCommit: {
                        viewModel.saveProfile()
                    })
                    CustomTextField(title: "Goal Weight:", value: $viewModel.goalWeight, onCommit: {
                        viewModel.saveProfile()
                    })
                    CustomTextField(
                        title: "Calorie Goal:",
                        value: Binding<Double>(
                            get: { Double(viewModel.dailyCalorieGoal) },
                            set: { viewModel.dailyCalorieGoal = Int($0) }
                        ),
                        onCommit: {
                            viewModel.saveProfile()
                        }
                    )
                    
                    WeightProgressView(
                        startWeight: userProfileViewModel.startWeight,
                        viewModel: userProfileViewModel,
                        onWeightChange: {
                            userProfileViewModel.saveProfile()
                        }
                    )
                    .padding(.vertical, 20)
                    
                }
                .background(Color.black)
                .padding(.top, 35)
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
                .background(
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color(UIColor.black))
                        .shadow(color: Color.cyan.opacity(0.3), radius: 14, x: 0, y: 10)
                        .padding(.horizontal, 30)
                )
                
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onTapGesture { hideKeyboard() }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $imageVM.profileImage)
            }
        }
    }
}

import SwiftUI

struct CustomTextField<Value>: View {
    let title: String
    @Binding var value: Value
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if Value.self == Double.self {
                    TextField("",
                              value: Binding(
                                get: { value as! Double },
                                set: { newValue in value = newValue as! Value }
                              ),
                              format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 19, weight: .light, design: .rounded))
                        .frame(width: 80)
                        .onSubmit {
                            onCommit?()
                        }
                        .onChange(of: value as! Double) { newValue, oldValue in
                            onCommit?()
                        }
                } else if Value.self == String.self {
                    TextField("",
                              text: Binding(
                                get: { value as! String },
                                set: { newValue in value = newValue as! Value }
                              ))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 19, weight: .light, design: .rounded))
                        .frame(width: 150)
                        .onSubmit {
                            onCommit?()
                        }
                } else {
                    EmptyView()
                }
            }
            Color.clear
                .frame(width: 250, height: 1)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

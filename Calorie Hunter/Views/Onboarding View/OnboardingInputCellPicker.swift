//
//  OnboardingInputCellPicker.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 14.03.25.
//

import SwiftUI

/// A reusable input cell for onboarding screens that allows the user to pick a value from a segmented control.
/// This view displays an optional system image, a title, and a segmented picker styled as a UISegmentedControl.
struct OnboardingInputCellPicker: View {
    // MARK: - Input Properties
    
    /// The title text displayed above the picker.
    var title: String
    
    /// An optional system image name to display above the title.
    var systemImageName: String? = nil
    
    /// An array of string options to be displayed in the segmented control.
    var options: [String]
    
    /// A binding to the selected option.
    @Binding var selection: String
    
    // MARK: - Environment
    
    /// Provides the current color scheme for dynamic styling.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Initializer
    
    /// Custom initializer that configures the UISegmentedControl appearance.
    /// - Parameters:
    ///   - title: The title text displayed above the picker.
    ///   - systemImageName: An optional system image name.
    ///   - options: An array of string options.
    ///   - selection: A binding to the currently selected option.
    init(title: String, systemImageName: String? = nil, options: [String], selection: Binding<String>) {
        self.title = title
        self.systemImageName = systemImageName
        self.options = options
        self._selection = selection
        
        // Configure the global appearance for UISegmentedControl.
        // Note: These changes affect all segmented controls in your app.
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.systemBlue  // Selected segment background color.
        UISegmentedControl.appearance().backgroundColor = UIColor.white  // Overall background color.
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            // Optionally display a system image if provided.
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    // Adjust image color based on the current color scheme.
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }
            
            // Display the title above the picker.
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            // Segmented Picker bound to the selection property.
            Picker("", selection: $selection) {
                // Iterate over options to create a picker segment for each one.
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
        }
        // Set a fixed size for the input cell.
        .frame(width: 180, height: 100)
        .background(
            // A rounded rectangle background with a subtle shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary)
                .shadow(radius: 3)
        )
    }
}

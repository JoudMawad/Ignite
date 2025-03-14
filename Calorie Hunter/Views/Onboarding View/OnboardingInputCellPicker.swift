//
//  OnboardingInputCellPicker.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 14.03.25.
//

import SwiftUI

struct OnboardingInputCellPicker: View {
    var title: String
    var systemImageName: String? = nil
    var options: [String]
    @Binding var selection: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 4) {
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
        }
        .frame(width: 200, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.primary)
                .shadow(radius: 3)
        )
    }
}


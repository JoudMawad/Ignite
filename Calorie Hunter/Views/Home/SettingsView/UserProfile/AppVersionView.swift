//
//  AppVersionView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 03.03.25.
//

import SwiftUI

struct AppVersionView: View {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        Text("Version \(appVersion) (Build \(buildNumber))")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding()
    }
}

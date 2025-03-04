//
//  Calorie_HunterApp.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 01.03.25.
//

import SwiftUI

@main
struct Calorie_HunterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

//
//  NavigationConfigurator.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

// NavigationConfigurator is a helper view that allows you to customize the appearance
// and behavior of a UINavigationController in SwiftUI.
// It immediately overrides the default navigation bar settings.
struct NavigationConfigurator: UIViewControllerRepresentable {
    // A closure that takes a UINavigationController and configures it.
    let configure: (UINavigationController) -> Void

    // Creates a dummy UIViewController that will be embedded in the SwiftUI view hierarchy.
    // This view controller is used to access the underlying UINavigationController.
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // Dispatch asynchronously to ensure the view controller is in the view hierarchy.
        DispatchQueue.main.async {
            // If the view controller is embedded in a UINavigationController,
            // execute the configuration closure to customize the navigation bar.
            if let navController = viewController.navigationController {
                self.configure(navController)
            }
        }
        return viewController
    }

    // This method is required by the protocol but isn't used in this case.
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

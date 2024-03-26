//
//  medTrackerApp.swift
//  medTracker
//
//  Created by Alumno on 16/10/23.
//

import SwiftUI
import Firebase

@main
struct medTrackerApp: App {
    // Initialize the configuration of the database
    init() {
        // Firebase configuration
        FirebaseApp.configure()
        // Changing color of selected segmented picker and its foreground color
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "blueGreen")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "blueGreen") ?? .black], for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}

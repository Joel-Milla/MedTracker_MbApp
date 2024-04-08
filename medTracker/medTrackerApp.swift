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
    
    // Use this variables to remove the badge count on the application when a user receives a notification
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .onAppear {
                    UNUserNotificationCenter.current().setBadgeCount(0)
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }
        }
    }
}

// This class is used to remove the badge number on the app when the user enters the application
import UIKit
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Perform any setup necessary when your application is launched.
        // For example, you could request notification authorization here.
        
        return true
    }
    
    // Add any other delegate methods you need here.
}

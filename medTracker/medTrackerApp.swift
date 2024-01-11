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
    @AppStorage("hasRequestedNotificationPermission") private var hasRequestedNotificationPermission = false
    // Initialize the configuration of the database
    init() {
        FirebaseApp.configure()
    }
    @StateObject var authentication = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authentication.isAuthenticated {
                if authentication.userRole == "Paciente" {
                    MainView()
                        .environmentObject(authentication)
                } else if authentication.userRole == "Doctor" {
                    MainDoctorView()
                        .environmentObject(authentication)
                } else {
                    ProgressView()
                }
            } else {
                WelcomeView()
                    .environmentObject(authentication)
                    .onAppear(perform: {
                        if !hasRequestedNotificationPermission {
                            requestNotificationPermission()
                            hasRequestedNotificationPermission = true
                        }    
                    })
            }
        }
    }
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Permission granted!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

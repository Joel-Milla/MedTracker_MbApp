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
                    if let symptomList = authentication.makeSymptomList(),
                       let registersList = authentication.makeRegisterList(),
                       let userModel = authentication.makeUserModel() {
                        MainView(
                            symptoms: symptomList, registers: registersList, user: userModel
                        )
                        .environmentObject(authentication)
                    } else {
                        Text("Didn't work")
                    }
                } else if authentication.userRole == "Doctor" {
                    if let userModel = authentication.makeUserModel(),
                       let patientList = authentication.makePatientList() {
                        MainDoctorView(user: userModel, listaPacientes: patientList)
                        .environmentObject(authentication)
                    } else {
                        Text("Didn't work")
                    }
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

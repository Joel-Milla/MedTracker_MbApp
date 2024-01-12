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
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if let userRole = authViewModel.user?.rol {
                if userRole == "Paciente" {
                    if let symptomList = authViewModel.makeSymptomList(),
                       let registersList = authViewModel.makeRegisterList(),
                       let userModel = authViewModel.makeUserModel() {
                        MainView(
                            symptoms: symptomList, registers: registersList, user: userModel
                        )
                        .environmentObject(authViewModel)
                    } else {
                        Text("Didn't work")
                    }
                } else if userRole == "Doctor" {
                    if let userModel = authViewModel.makeUserModel(),
                       let patientList = authViewModel.makePatientList() {
                        MainDoctorView(user: userModel, patientsList: patientList)
                        .environmentObject(authViewModel)
                    } else {
                        Text("Didn't work")
                    }
                } else {
                   ProgressView()
                }
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
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

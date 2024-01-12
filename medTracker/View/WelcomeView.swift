//
//  WelcomeView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/01/24.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasRequestedNotificationPermission") private var hasRequestedNotificationPermission = false
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
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
            AuthenticationView()
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

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Permission granted!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    WelcomeView()
}

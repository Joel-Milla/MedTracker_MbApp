//
//  WelcomeView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/01/24.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasRequestedNotificationPermission") private var hasRequestedNotificationPermission = false
    @StateObject var authViewModel = AuthViewModel() // ViewModel in charge of logIn or registering
    
    var body: some View {
        // When there is currently currenlty a user or role, show the main windows of the symptoms
        if let userRole = authViewModel.user?.rol {
            if userRole == "Paciente" {
                // With the information obtained from authViewModel that contains the user, create the models that will contain all the information and pass them to the main view
                if let symptomList = authViewModel.makeSymptomList(),
                   let registersList = authViewModel.makeRegisterList(),
                   let userModel = authViewModel.makeUserModel() {
                    MainView(
                        symptoms: symptomList, registers: registersList, user: userModel
                    )
                    .environmentObject(authViewModel)
                } else {
                    Text("Hubo un problema")
                }
            } // Show the view of the doctor
            else if userRole == "Doctor" {
                // With the information obtained from authViewModel that contains the user, create the models that will contain all the information and pass them to the main view
//                if let userModel = authViewModel.makeUserModel(),
//                   let patientList = authViewModel.makePatientList() {
//                    MainDoctorView(user: userModel, patientsList: patientList)
//                        .environmentObject(authViewModel)
//                } else {
//                    Text("Hubo un problema")
//                }
                VStack(spacing: 30) {
                    Text("Utilice la siguiente página web para ver los datos:")
                    Link("MedTracker Dashboard", destination: URL(string: "https://medtracker-app.netlify.app/")!)
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Text("Cerrar Sesión")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
            }
            else {
                // When there is currently no rol, show a progress view and sign out so the user can register
                ProgressView()
            }
        } else {
            // When there is no role, show the authentication view.
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
            customPrint("Permission granted!")
        } else if let error = error {
            customPrint(error.localizedDescription)
        }
    }
}

#Preview {
    WelcomeView()
}

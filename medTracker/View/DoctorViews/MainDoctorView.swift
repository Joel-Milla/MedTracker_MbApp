//
//  MainDoctorView.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

import SwiftUI
import FirebaseAuth

struct MainDoctorView: View {
    @StateObject var user: UserModel
    @StateObject var patientsList: PatientList
    
    var body: some View {
        NavigationStack {
            VStack {
                switch patientsList.state {
                case .isLoading:
                    ProgressView() //Loading animation
                case .isEmpty:
                    //Calls a view to show that the list is empty
                    EmptyListView(
                        title: "No hay pacientes registrados",
                        message: "Favor de pedirle a los usuarios que compartan su información.",
                        nameButton: "Agregar Sintoma"
                    )
                case .complete:
                    List {
                        ForEach(patientsList.patientsList , id: \.self) { patient in
                            NavigationLink {
                                AnalysisDoctorView(patientsData: PatientsData(patient: patient, repository: user.repository))
                            } label: {
                                rowPatient(patient: patient)
                            }
                            
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        /*Button("Sign Out"){
                         authentication.signOut()
                         }
                         .foregroundColor(Color.red)*/
//                        DoctorProfileView(user: user, createAction: user.makeCreateAction())
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    
                }
            }
        }
    }
}

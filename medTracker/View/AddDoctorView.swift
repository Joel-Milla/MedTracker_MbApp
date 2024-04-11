//
//  AddDoctorView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 11/04/24.
//

import SwiftUI

struct AddDoctorView: View {
    // Variable to hold the information to show
    @ObservedObject var doctorsViewModel: DoctorsViewModel // Add observed object so when doctors array changes on main view, this also changes. The doctors array inside hold a reference to the doctors array inside the previous user
    // Helper variables
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Agregar Doctor")) {
                        TextField("Email de doctor", text: $doctorsViewModel.newDoctor)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            // Groupped style to be applied to the inputs. Same as register and log in
                            .inputStyle()
                        
                        Button(action: {
                            doctorsViewModel.addDoctor()
                        }, label: {
                            // Use changingText to show a progressView when the request is loading
                            ChangingText(state: $doctorsViewModel.state, title: "Compartir información")
                        })
                        .gradientStyle() // apply gradient style
                    }
                    
                    Section(header: Text("Doctores Registrados")) {
                        // Depending on the doctors of the array, show different views
                        if doctorsViewModel.doctors.isEmpty {
                            EmptyListView(
                                title: "No hay doctores registrados",
                                message: "Por favor agrega doctores para compartir los datos.",
                                nameButton: "Nothing"
                            )
                            .frame(maxWidth: .infinity) // Set the width to infinity to center the view inside the section
                        } else {
                            ForEach(doctorsViewModel.doctors, id: \.self) { doctor in
                                Text(doctor)
                                    .font(.body)
                                    .padding(8)
                            }
                            .onDelete(perform: doctorsViewModel.removeDoctor)
                        }
                    }
                }
            }
            // MARK: The following edits are in charge of a good user experience
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(doctorsViewModel.addDoctor)
            // Show alert to tell the user that there is an error
            .alert("Error al guardar datos", error: $doctorsViewModel.error)
            // Dismiss the view
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            // MARK: Ending of general user experience
        }
    }
}

//#Preview {
//    AddDoctorView()
//}

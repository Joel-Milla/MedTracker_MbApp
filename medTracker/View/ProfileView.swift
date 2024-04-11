//
//  profile.swift
//  medTracker
//
//  Created by Alumno on 17/10/23.
//

import SwiftUI

/**********************
 This view shows the profile data of the user and allows the user to edit it.
 **********************************/
struct ProfileView: View {
    // Variable that holds the information of the user
    @ObservedObject var user: UserModel
    @EnvironmentObject var authentication: AuthViewModel
    // Variable that will hold the request to make a new user
    @StateObject var formViewModel: FormViewModel<User>
    // View variables
    @State private var isEditing = false
    let optionsSex = ["-", "Masculino", "Femenino", "Prefiero no decir"]
    @State var showAddDoctorView = false

    var body: some View {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                // In each section, separate the values that can be editted and that can not be editted
                Form {
                    // Name and phone number
                    Section {
                        if isEditing {
                            Text("Nombre completo: \(user.name)")
                            HStack {
                                Text("Teléfono:")
                                TextField("+81 2611 1857", text: $formViewModel.phone)
                            }
                        } else {
                            Text("Nombre completo: \(user.name)")
                            Text("Teléfono: \(user.phone)")
                        }
                    } header: {
                        Text("Datos personales")
                    }
                    
                    // Modify height, birthdate, sex
                    Section {
                        if isEditing {
                            HStack {
                                Text("Estatura:")
                                TextField("1.80", text: $formViewModel.height)
                                    .keyboardType(.decimalPad)
                            }
                            DatePicker("Fecha de Nacimiento",
                                       selection: $formViewModel.birthdate, in: HelperFunctions.dateRange,
                                       displayedComponents: .date)
                            
                            Picker("Sexo", selection: $formViewModel.sex) {
                                ForEach(optionsSex, id: \.self) { sex in
                                    Text(sex).tag(sex)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        } else {
                            Text("Estatura: \(user.height)")
                            HStack {
                                Text("Fecha de nacimiento:")
                                Spacer() // Add spacer so the view seems similar as when editing
                                Text(user.formattedDateOfBirth)
                            }
                            HStack {
                                Text("Sexo:")
                                Spacer()
                                Text(user.sex)
                            }
                        }
                    } header: {
                        Text("Datos fijos")
                    }
                    
                    // Clinical history
                    Section {
                        if isEditing {
                            Text("Antecedentes médicos:")
                            TextEditor(text: $formViewModel.formattedClinicalHistory)
                        } else {
                            Text("Antecedentes médicos:")
                            ScrollView {
                                Text(user.clinicalHistory)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                            }
                            .frame(minHeight: 0, maxHeight: 22 * 10)
                        }
                    } header: {
                        Text("Historial Clínico")
                    }
                    
                    // Button to open the view that shares data with the doctor
                    Button(action: { showAddDoctorView = true }) {
                        Text("Enviar datos a mi doctor")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("mainBlue"))
                            .cornerRadius(8)
                            .listRowBackground(Color.clear) // Makes the row background transparent
                    }
                    
                    // Button to log out
                    Button {
                        authentication.signOut()
                    } label: {
                        Text("Cerrar Sesión")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Perfil")
            // The buttons modify if the view keeps in edit mode or not
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            // Delete information that the user wrote when editting when clicking cancel
                            formViewModel.value = user.user
                            isEditing = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Done") {
                            formViewModel.submit()
                        }
                    } else {
                        Button("Editar") {
                            // Change to editing ode
                            isEditing = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddDoctorView, content: {
                AddDoctorView(doctorsViewModel: user.createAddDoctorViewModel())
            })
            // MARK: The following edits are in charge of a good user experience
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .alert("Error al guardar datos", error: $formViewModel.error)
            .onChange(of: formViewModel.state) { newValue in
                if (newValue == .successfullyCompleted ) {
                    isEditing = false
                }
            }
            // MARK: Ending of general user experience
    }
}

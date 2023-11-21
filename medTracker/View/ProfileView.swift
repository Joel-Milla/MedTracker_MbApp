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
    let tipos = ["Masculino", "Femeninio", "Prefiero no decir"]
    
    @ObservedObject var user: UserModel
    @EnvironmentObject var authentication: AuthViewModel
    @State private var draftUser: UserModel = UserModel()

    @State private var isEditing = false

    @State private var error:Bool = false
    @State private var errorMessage: String = ""
    
    typealias CreateAction = (User) async throws -> Void
    let createAction: CreateAction
    
    var body: some View {
        VStack() {
            NavigationStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100, alignment: .center)
                    .clipShape(Circle())
                    .clipped()
                Form {
                    Button("Sign Out", action: {
                        authentication.signOut()
                    }).foregroundStyle(Color.red)
                    
                    Section {
                        if isEditing {
                            HStack {
                                Text("Nombre(s)")
                                TextField("Joel Alejandro", text: $draftUser.user.nombre)
                            }
                            HStack {
                                Text("Apellido Paterno")
                                TextField("Milla", text: $draftUser.user.apellidoPaterno)}
                            HStack {
                                Text("Apellido Materno")
                                TextField("Lopez", text: $draftUser.user.apellidoMaterno)}
                            HStack {
                                Text("Telefono")
                                TextField("+81 2611 1857", text: $draftUser.user.telefono)}
                        } else {
                            Text("Nombre: \(user.user.nombre)")
                            Text("Apellido Paterno: \(user.user.apellidoPaterno)")
                            Text("Apellido Materno: \(user.user.apellidoMaterno)")
                            Text("Telefono: \(user.user.telefono)")
                        }
                    } header: {
                        Text("Datos personales")
                    }
                    
                    Section {
                        if isEditing {
                            HStack {
                                Text("Estatura")
                                TextField("1.80", text: $draftUser.user.estaturaString)
                                    .keyboardType(.decimalPad)
                            }
                            
                        } else {
                            Text("Estatura: \(String(format: "%.1f", user.user.estatura))")
                        }
                    } header: {
                        Text("Datos fijos")
                    }
                    
                    Section {
                        if isEditing {
                            Text("Antecedentes:")
                            TextEditor(text: $draftUser.user.antecedentes)
                        } else {
                            Text("Antecedentes:")
                            Text("\(user.user.antecedentes)")
                                .lineLimit(10)
                        }
                    } header: {
                        Text("Historial Clinico")
                    }
                }
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isEditing {
                            Button("Cancel") {
                                // Borrar informacion de draft user
                                draftUser.user = user.user
                                isEditing = false
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isEditing {
                            Button("Done") {
                                // Guardar informacion en user y sandbox
                                let validationResult = draftUser.user.error()
                                if validationResult.0 {
                                    error = true
                                    errorMessage = validationResult.1
                                }
                                else {
                                    user.user = draftUser.user
                                    createUser(user: user.user)
                                    isEditing = false
                                }
                            }
                        } else {
                            Button("Edit") {
                                // Modo normal
                                isEditing = true
                            }
                        }
                    }
                }
                .alert(isPresented: $error) {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    private func createUser(user: User) {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await
                createAction(user) //call the function that adds the user to the database
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
            }
        }
    }
}


struct profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: UserModel(), createAction: { _ in })
    }
}

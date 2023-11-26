//
//  AddDoctorView.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

import SwiftUI

struct AddDoctorView: View {
    @ObservedObject var user: UserModel
    @State var email: String = ""
    @State var emailFound = false
    @State var progress: StateRequest = .complete
    @Environment(\.dismiss) var dismiss
    
    @State var existError = false
    @State var errorMessage = ""
    
    // Variables to write on database
    typealias WritePatient = (String, User) async throws -> Void
    let writePatient: WritePatient
    
    typealias CreateAction = (User) async throws -> Void
    let createAction: CreateAction
    
    typealias DeleteAction = (String) async throws -> Void
    let deletePatient: DeleteAction
    
    enum StateRequest {
        case loading
        case complete
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Agregar Doctor")) {
                        TextField("Email de doctor", text: $email)
                            .textContentType(.emailAddress)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("mainBlue"), lineWidth: 1)
                            )
                        
                        Button(action: {
                            if email != "" {
                                Task {
                                    await addDoctorIfRoleMatches()
                                }
                            } else {
                                existError = true
                                errorMessage = "Por favor ingresa un email valido."
                            }
                        }, label: {
                            if progress == .complete {
                                Text("Compartir información")
                            } else {
                                ProgressView()
                            }
                        })
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    
                    Section(header: Text("Doctores Registrados"), footer: customFooterView) {
                        if user.user.arregloDoctor.isEmpty {
                            HStack {
                                Spacer()
                                EmptyListView(
                                    title: "No hay doctores registrados",
                                    message: "Por favor agrega doctores para compartir los datos.",
                                    nameButton: "Nothing"
                                )
                                Spacer()
                            }
                        } else {
                            ForEach(user.user.arregloDoctor, id: \.self) { email in
                                Text(email)
                                    .font(.body)
                                    .padding(8)
                            }
                            .onDelete(perform: deletePatient)
                        }
                    }
                }
                //Spacer()
            }
            .keyboardToolbar()
            .navigationTitle("Compartir datos")
            .alert(isPresented: $existError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var customFooterView: some View {
        HStack {
            if !user.user.arregloDoctor.isEmpty {
                Text("Desliza la fila para eliminar")
            }
        }
    }
    
    private func deletePatient(at offsets: IndexSet) {
        // Delete info from database
        for index in offsets {
            let emailToDelete = user.user.arregloDoctor[index]
            Task {
                try await deletePatient(emailToDelete)
            }
        }
        
        // Implement deletion logic for locally stored information.
        user.user.arregloDoctor.remove(atOffsets: offsets)
        user.saveUserData()
        
        // modify data in database
        createUser(user: user.user)
    }
    
    func addDoctorIfRoleMatches() async {
        self.progress = .loading
        do {
            email = email.lowercased()
            let doctorRole = try await HelperFunctions.fetchUserRole(email: email)
            if doctorRole == "Doctor" {
                if user.user.arregloDoctor.contains(where: {
                    $0 == email
                }) {
                    existError = true
                    errorMessage = "El email ya esta agregado."
                    self.progress = .complete
                } else {
                    DispatchQueue.main.async {
                        // modifying data locally
                        user.user.arregloDoctor.append(email)
                        user.saveUserData()
                        
                        // modify data in database
                        createUser(user: user.user)
                        writeDoctor(email: email, user: user.user)
                        
                        // reset variables
                        email = ""
                        self.progress = .complete
                    }
                }
            } else {
                self.progress = .complete
                existError = true
                errorMessage = "No se encontro el email como valido."
            }
        } catch {
            // Handle any errors
            print(error.localizedDescription)
            self.progress = .complete
            existError = true
            errorMessage = "No se encontro el email como valido."
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
    
    private func writeDoctor(email: String, user: User) {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await
                writePatient(email, user) //call the function that adds the user to the database
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
            }
        }
    }
}

struct AddDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        AddDoctorView(user: UserModel(), writePatient: { _, _ in }, createAction: { _ in }, deletePatient: { _ in })
    }
}

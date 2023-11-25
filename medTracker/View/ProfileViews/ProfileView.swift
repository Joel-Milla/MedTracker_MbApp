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
    @ObservedObject var user: UserModel
    @EnvironmentObject var authentication: AuthViewModel
    @State private var draftUser: UserModel = UserModel()
    @State private var keyboardHeight: CGFloat = 35
    
    @State private var isEditing = false
    
    var sexo = ["-", "Masculino", "Femenino", "Prefiero no decir"]
    @State var estatura = ""
    @State private var selectedSexo = "Masculino" // Default value
    
    @State private var error:Bool = false
    @State private var errorMessage: String = ""
    
    typealias CreateAction = (User) async throws -> Void
    let createAction: CreateAction
    
    @State var showAddDoctorView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100, alignment: .center)
                    .clipShape(Circle())
                    .clipped()
                Form {
                    Section {
                        if isEditing {
                            HStack {
                                Text("Nombre completo:")
                                TextField("Joel Alejandro", text: $draftUser.user.nombreCompleto)
                            }
                            HStack {
                                Text("Telefono:")
                                TextField("+81 2611 1857", text: $draftUser.user.telefono)}
                        } else {
                            Text("Nombre completo: \(user.user.nombreCompleto)")
                            Text("Telefono: \(user.user.telefono)")
                        }
                    } header: {
                        Text("Datos personales")
                    }
                    
                    Section {
                        if isEditing {
                            HStack {
                                Text("Estatura:")
                                TextField("1.80", text: $draftUser.user.estatura)
                                    .keyboardType(.decimalPad)
                            }
                            DatePicker("Fecha de Nacimiento",
                                       selection: $draftUser.user.fechaNacimiento,
                                       displayedComponents: .date)
                            
                            Picker("Sexo", selection: $selectedSexo) {
                                ForEach(sexo, id: \.self) { sexo in
                                    Text(sexo).tag(sexo)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onAppear {
                                self.selectedSexo = draftUser.user.sexo
                            }
                            .onChange(of: selectedSexo) { newValue in
                                draftUser.user.sexo = newValue
                            }
                        } else {
                            Text("Estatura: \(user.user.estatura)")
                            HStack {
                                Text("Fecha de nacimiento:")
                                Spacer()
                                Text(user.user.formattedDateOfBirth)
                            }
                            
                            HStack {
                                Text("Sexo:")
                                Spacer()
                                Text(draftUser.user.sexo)
                            }
                        }
                    } header: {
                        Text("Datos fijos")
                    }
                    
                    Section {
                        if isEditing {
                            Text("Antecedentes:")
                            TextEditor(text: $draftUser.user.formattedAntecedentes)
                        } else {
                            Text("Antecedentes:")
                            ScrollView {
                                Text(user.user.antecedentes)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                            }
                            .frame(minHeight: 0, maxHeight: 22 * 10)
                        }
                    } header: {
                        Text("Historial Clinico")
                    }
                    
                    Section("Sesion") {
                        Button("Send Data to Doctor"){}
                            .onTapGesture {
                                showAddDoctorView = true
                            }
                            .foregroundColor(Color.blue)
                        
                        Button("Sign Out"){}
                            .onTapGesture {
                                authentication.signOut()
                            }
                            .foregroundColor(Color.red)
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
                            Button("Editar") {
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
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .sheet(isPresented: $showAddDoctorView, content: {
                AddDoctorView(user: user)
            })
        }
        // Keyboard modifier
        .padding(.bottom, keyboardHeight) // Apply the dynamic padding here
        .onAppear {
            // Set up keyboard show/hide observers
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height - 40
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 35 // No extra padding when keyboard is hidden
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .ignoresSafeArea(.keyboard)
        
        
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

// To dismiss keyboard on type
extension UIApplication {
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: UserModel(), createAction: { _ in })
    }
}

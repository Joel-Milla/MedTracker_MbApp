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
    @State private var draftUser: User = User()
    @State private var keyboardHeight: CGFloat = 48
    @ObservedObject var symptoms : SymptomList
    @State private var isEditing = false
    
    var sexo = ["-", "Masculino", "Femenino", "Prefiero no decir"]
    @State var estatura = ""
    @State private var selectedSexo = "Masculino" // Default value
    
    @State private var error:Bool = false
    @State private var errorMessage: String = ""
    
    typealias CreateAction = (User) async throws -> Void
    let createAction: CreateAction
    
    typealias CreateAction2 = (Symptom) async throws -> Void
    let createAction2: CreateAction2
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .year, value: -120, to: Date())!
        let end = Date()
        return start...end
    }()
    
    @State var showAddDoctorView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .overlay(Circle().stroke(Color("mainBlue"), lineWidth: 2))
                Form {
                    Section {
                        if isEditing {
                            Text("Nombre completo: \(user.user.nombreCompleto)")
                            HStack {
                                Text("Teléfono:")
                                TextField("+81 2611 1857", text: $draftUser.telefono)}
                        } else {
                            Text("Nombre completo: \(user.user.nombreCompleto)")
                            Text("Teléfono: \(user.user.telefono)")
                        }
                    } header: {
                        Text("Datos personales")
                    }
                    
                    Section {
                        if isEditing {
                            HStack {
                                Text("Estatura:")
                                TextField("1.80", text: $draftUser.estatura)
                                    .keyboardType(.decimalPad)
                            }
                            DatePicker("Fecha de Nacimiento",
                                       selection: $draftUser.fechaNacimiento, in: dateRange,
                                       displayedComponents: .date)
                            
                            Picker("Sexo", selection: $selectedSexo) {
                                ForEach(sexo, id: \.self) { sexo in
                                    Text(sexo).tag(sexo)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onAppear {
                                self.selectedSexo = draftUser.sexo
                            }
                            .onChange(of: selectedSexo) { newValue in
                                draftUser.sexo = newValue
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
                                Text(draftUser.sexo)
                            }
                        }
                    } header: {
                        Text("Datos fijos")
                    }
                    
                    Section {
                        if isEditing {
                            Text("Antecedentes médicos:")
                            TextEditor(text: $draftUser.formattedAntecedentes)
                        } else {
                            Text("Antecedentes médicos:")
                            ScrollView {
                                Text(user.user.antecedentes)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                            }
                            .frame(minHeight: 0, maxHeight: 22 * 10)
                        }
                    } header: {
                        Text("Historial Clínico")
                    }
                    
                    Section("") {
                        Button(action: { showAddDoctorView = true }) {
                            Text("Enviar datos a mi doctor")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("mainBlue"))
                                .cornerRadius(8)
                        }
                        
                        Button {
                            for (index,_) in symptoms.symptoms.enumerated() {
                                symptoms.symptoms[index].notificacion = ""
                                modifySymptom(symptomModification: symptoms.symptoms[index])
                                cancelAllNotification()
                            }
                            
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
                .keyboardToolbar()
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isEditing {
                            Button("Cancel") {
                                // Borrar informacion de draft user
                                draftUser = user.user
                                isEditing = false
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isEditing {
                            Button("Done") {
                                // Guardar informacion en user y sandbox
                                let validationResult = draftUser.error()
                                if validationResult.0 {
                                    error = true
                                    errorMessage = validationResult.1
                                }
                                else {
                                    user.user = draftUser
                                    //user.saveUserData()
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
            .sheet(isPresented: $showAddDoctorView, content: {
                AddDoctorView(user: user, writePatient: user.writePatient(), createAction: user.makeCreateAction(), deletePatient: user.makeDeleteAction())
            })
        }
        // Keyboard modifier
        .padding(.bottom, keyboardHeight) // Apply the dynamic padding here
        .onAppear {
            // Set up keyboard show/hide observers
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    if authentication.userRole != "Doctor" {
                        keyboardHeight = keyboardFrame.height - 40
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                if authentication.userRole != "Doctor" {
                    keyboardHeight = 48 // No extra padding when keyboard is hidden
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .ignoresSafeArea(.keyboard)
        
        
    }
    
    private func modifySymptom(symptomModification: Symptom) {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await createAction2(symptomModification) //call the function that adds the symptom to the database
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
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
    
    //private func
}

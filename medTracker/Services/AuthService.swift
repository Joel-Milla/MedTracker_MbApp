//
//  AuthService.swift
//  medTracker
//
//  Created by Alumno on 18/11/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

/**********************
 This class contains helper functions to authenticate the user (the log in view and register a new user)
 **********************************/
@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
//    @Published var isAuthenticated = false
    // The next two variables are used to keep the model update when creating an account, because the update firebaseDisplayName or the role from firebase are written way after the functions are ran. So the variables keep updated everything when creating an account. When using log in are not necessary because are already created.
    private var name: String?
    private var role: String?
    
    let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    /**********************
     Important initialization methods
     **********************************/
    init() {
        // Always listen inside an object when the auth changes. The closure after will execute every time something changes
        listener = auth.addStateDidChangeListener ({ _, firebaseUser in
            if let firebaseUser = firebaseUser {
                if let name = self.name, let role = self.role {
                    // This will run when the user creates an account
                    self.user = User(from: firebaseUser, name: name, role: role)
                } else {
                    // This will run when a user signs in
                    self.user = User(from: firebaseUser)
                    // The task fetches the role of the user that just logged in and assings it.
                    Task {
                        self.user?.rol = try await HelperFunctions.fetchUserRole(email: self.user?.email ?? "")
                    }
                }
            } else {
                // Handle the scenario when singin out
                self.user = nil // or some default initialization
                self.name = nil
                self.role = nil
            }
        })
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Function to create an account based on a name, email, and password.
    func createAccount(name: String, email: String, password: String, confirmPassword: String, role: String) async throws {
        // Validate if everything is correct before making the request to firebase
        if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            throw HelperFunctions.ErrorType.invalidInput("Llena todos los valores")
        } else if (password != confirmPassword) {
            throw HelperFunctions.ErrorType.invalidInput("Las contraseñas no coinciden")
        }
        // Save data into the model and make the request to firebase to create the user
        self.name = name
        self.role = role
        do {
            // Make requests to firebase
            let result = try await auth.createUser(withEmail: email, password: password)
            try await result.user.updateProfile(\.displayName, to: name) // Save the name of the user
            try await save(role, of: result.user.uid, with: email)
            try await createUser(of: email) // create data of user in firestore
        } catch {
            customPrint("[AuthService] Error creating account: \(error.localizedDescription)")
            // This function gets the error and saves it correclty
            try HelperFunctions.handleFirebaseAuthError(code: error)
        }
    }
    
    // Function that tries to sign in.
    func signIn(email: String, password: String) async throws {
        // Validate if everything is correct before making the request to firebase
        if (email.isEmpty || password.isEmpty) {
            throw HelperFunctions.ErrorType.invalidInput("Llena todos los valores")
        }
        do {
            // Make request to firebase
            try await auth.signIn(withEmail: email, password: password)
        } catch {
            customPrint("[AuthService] Error signin in: \(error.localizedDescription)")
            // This function gets the error and saves it
            try HelperFunctions.handleFirebaseAuthError(code: error)
        }
    }
    
    // Function to sign out.
    func signOut() throws {
        try auth.signOut()
    }
    
    // Create the role of the user in the database
    func save(_ role: String, of id: String, with email: String) async throws {
        let lowerCaseEmail = email.lowercased()
        let document = Firestore.firestore().collection("Roles").document(lowerCaseEmail)
        try await document.setData([
            "role": role,
            "id": id,
            "email": email
        ])
    }
    
    // Save information of the user in firebase
    func createUser(of email: String) async throws {
        let lowerCaseEmail = email.lowercased()
        let document = Firestore.firestore().collection("Users").document(lowerCaseEmail)
        try await document.setData(from: self.user)
    }
}

// Function to update the profile
private extension FirebaseAuth.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}

// Convert the user information into the userModel and save it
private extension User {
    init(from firebaseUser: FirebaseAuth.User, name: String? = nil, role: String? = nil) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? name ?? "[AuthService] Nombre desconocido"
        self.rol = role ?? "[AuthService] Rol desconocido"
        self.email = firebaseUser.email ?? "[AuthService] Email desconocido"
        self.phone = ""
        self.clinicalHistory = ""
        self.sex = ""
        self.birthdate = Date()
        self.height = ""
        self.doctors = []
    }
}

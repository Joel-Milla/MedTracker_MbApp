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
    @Published var isAuthenticated = false
    // The next two variables are used to keep the model update when creating an account, because the update firebaseDisplayName or the role from firebase are written way after the functions are ran. So the variables keep updated everything when creating an account. When using log in are not necessary because are already created.
    private var name: String?
    private var role: String?
    
    let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    /**********************
     Important initialization methods
     **********************************/
    init() {
        listener = auth.addStateDidChangeListener ({ _, firebaseUser in
            self.isAuthenticated = firebaseUser != nil
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
                // Handle the scenario where firebaseUser is nil
                self.user = nil // or some default initialization
            }
        })
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Function to create an account based on a name, email, and password.
    func createAccount(name: String, email: String, password: String, role: String) async throws {
        self.name = name
        self.role = role
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            try await result.user.updateProfile(\.displayName, to: name)
            HelperFunctions.write(email, inPath: "email.JSON")
            // Save the role in Firestore
            let db = Firestore.firestore()
            //try await db.collection("users").document(result.user.uid).setData([
            try await db.collection("Roles").document(email).setData([
                "role": role,
                "id": result.user.uid,
                "email": email
            ])
        } catch {
            print("[AuthService] Error while creating the account: \(error)")
        }
        
    }
    
    // Function that tries to sign in.
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    // Function to sign out.
    func signOut() throws {
        try auth.signOut()
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

// Convert the user information
private extension User {
    init(from firebaseUser: FirebaseAuth.User, name: String? = nil, role: String? = nil) {
        self.id = firebaseUser.uid
        self.nombreCompleto = firebaseUser.displayName ?? name ?? "[AuthService] Nombre desconocido"
        self.rol = role ?? "[AuthService] Rol desconocido"
        self.email = firebaseUser.email ?? "[AuthService] Email desconocido"
        self.telefono = ""
        self.antecedentes = ""
        self.sexo = ""
        self.fechaNacimiento = Date()
        self.estatura = ""
        self.arregloDoctor = []
    }
}

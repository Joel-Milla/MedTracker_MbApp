//
//  AuthViewModel.swift
//  medTracker
//
//  Created by Alumno on 18/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/**********************
 This class contains all the data that  helps to authenticate the user. From sign in to creating a new account.
 **********************************/

@MainActor
class AuthViewModel: ObservableObject {
    /**********************
     Personal data of the user
     **********************************/
    @Published var user: User?
    var userRole: String  {
        guard let userRol = user?.rol else {
            print("[AuthViewModel] Error: User role not found")
            return "Unknown role"
        }
        return userRol
    }
    var userEmail: String  {
        guard let userMail = user?.email else {
            print("[AuthViewModel] Error: Email not found")
            return "Unknown email"
        }
        return userMail
    }
    
    /**********************
     Variables related to firebase
     **********************************/
    private let authService = AuthService()
    @Published var state: State = .idle // Variable to know the state of the request of firebase
    @Published var isAuthenticated = false // to know if the user is authenticated or not
    
    /**********************
     Important initialization method
     **********************************/
    init() {
        // To know the current state of the user.
        authService.$isAuthenticated.assign(to: &$isAuthenticated)
        authService.$user.assign(to: &$user)
        fetchUserRole()
    }
    
    enum State {
        case idle
        case isLoading
    }
    
    /**********************
     Helper functions
     **********************************/
    // Function to sign out and reset all the data
    func signOut() {
        Task {
            do {
                try authService.signOut() // Reset the state of the authService
                // The next lines of code delete all the information of the current user
                deleteFiles()
                isAuthenticated = false
                
            } catch {
                print("[AuthViewModel] Error while signin out: \(error)")
            }
        }
    }
    
    // Function that performs a shallow search on the files created and deletes them
    private func deleteFiles() {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let documentsDirectoryPath = documentsDirectory.path
            
            let filesURLs = try fileManager.contentsOfDirectory(atPath: documentsDirectoryPath)
            
            for file in filesURLs {
                let fullPath = documentsDirectory.appendingPathComponent(file).path(percentEncoded: true)
                try fileManager.removeItem(atPath: fullPath)
            }
        } catch {
            fatalError("[AuthViewModel] Error while deleting the files: \(error)")
        }
    }
    
    // Fetch users role from firestore
    func fetchUserRole() {
        Task {
            user?.rol = try await HelperFunctions.fetchUserRole(email: userEmail)
        }
    }
    // Returns the symptom list object with current user
    func makeSymptomList() -> SymptomList? {
        guard let user = user else {
            return nil
        }
        return SymptomList(repository: Repository(user: user))
    }
    // Returns the register list with current user
    func makeRegisterList() -> RegisterList? {
        guard let user = user else {
            return nil
        }
        return RegisterList(repository: Repository(user: user))
    }
    // Returns the user model with the current user
    func makeUserModel() -> UserModel? {
        guard let user = user else {
            return nil
        }
        return UserModel(repository: Repository(user: user))
    }
    // Returns patients list of the current user
    func makePatientList() -> PatientList? {
        guard let user = user else {
            return nil
        }
        return PatientList(repository: Repository(user: user))
    }
    
    // returns a closure of a form to sign in
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(action: authService.signIn(email:password:))
    }
    
    // returns a closure of a form to create an account
    func makeCreateAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(action: authService.createAccount(name:email:password:role:))
    }
}

extension AuthViewModel {
    class SignInViewModel: FormViewModel<(email: String, password: String)> {
        convenience init(action: @escaping Action) {
            self.init(initialValue: (email: "", password: ""), action: action)
        }
    }
    
    class CreateAccountViewModel: FormViewModel<(name: String, email: String, password: String, role: String)> {
        convenience init(action: @escaping Action) {
            self.init(initialValue: (name: "", email: "", password: "", role: "Paciente"), action: action)
        }
    }
}

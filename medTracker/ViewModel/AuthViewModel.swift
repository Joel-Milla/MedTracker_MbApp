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
    
    
    @Published var email = "" {
        didSet {
            let lowercasedEmail = email.lowercased()
            HelperFunctions.write(lowercasedEmail, inPath: "email.JSON")
        }
    }
    @Published var password = ""

    var userRole: String  {
        guard let userRol = user?.rol else {
            print("[AuthViewModel] Error: User role not found")
            return "Unkown role"
        }
        return userRol
    }
    var userId: String  {
        guard let userId = user?.id else {
            print("[AuthViewModel] Error: Id not found")
            return "Id Unkown"
        }
        return userId
    }
    
    var userEmail: String  {
        guard let userMail = user?.email else {
            print("[AuthViewModel] Error: Email not found")
            return "Unkown email"
        }
        return userMail
    }
    
    /**********************
     Variables related to firebase
     **********************************/
    private let authService = AuthService()
    @Published var signInErrorMessage: String?
    @Published var registrationErrorMessage: String?
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
    
    // The function sends a request to firebase to confirm the email and password entered.
    func signIn() {
        Task {
            state = .isLoading
            do {
                try await authService.signIn(email: email, password: password)
                let role = try await HelperFunctions.fetchUserRole(email: userEmail)
                self.user?.id = role
            } catch {
                signInErrorMessage = error.localizedDescription
            }
            state = .idle
        }
    }
    
    // Function to sign out and reset all the data
    func signOut() {
        Task {
            do {
                try authService.signOut() // Reset the state of the authService
                
                // The next lines of code delete all the information of the current user
                email = ""
                password = ""
                signInErrorMessage = nil
                registrationErrorMessage = nil
                let eliminar = ["email.JSON", "Registers.JSON", "Symptoms.JSON", "User.JSON"]
                for path in eliminar {
                    HelperFunctions.write("-----", inPath: path)
                }
                isAuthenticated = false
                
            } catch {
                signInErrorMessage = error.localizedDescription
            }
        }
    }
    
    // Fetch users role from firestore
    func fetchUserRole() {
        Task {
            user?.rol = try await HelperFunctions.fetchUserRole(email: userId)
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
        let viewModel = CreateAccountViewModel(initialValue: (name: "", email: "", password: "", role: "Paciente"), action: authService.createAccount)
        viewModel.$error
            .compactMap { $0 }
            .map { $0.localizedDescription }
            .assign(to: &$registrationErrorMessage)
        return viewModel
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

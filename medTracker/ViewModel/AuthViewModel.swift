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
    @Published var userRole: String = ""
    
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
                let role = try await HelperFunctions.fetchUserRole(email: email)
                userRole = role
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
                userRole = ""
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
        var emailJSON = ""
        if let datosRecuperados = try? Data.init(contentsOf: HelperFunctions.filePath("email.JSON")) {
            if let datosDecodificados = try? JSONDecoder().decode(String.self, from: datosRecuperados) {
                print("Entro al json")
                emailJSON = datosDecodificados
                Task {
                    do {
                        userRole = try await HelperFunctions.fetchUserRole(email: emailJSON)
                    } catch {
                        print("No se encontro el user role")
                    }
                }
            }
        }
        if let email = authService.auth.currentUser?.email {
            print("Entro al if para hacer llamada api")
            Task {
                do {
                    userRole = try await HelperFunctions.fetchUserRole(email: email)
                } catch {
                    print("No se encontro el user role")
                }
            }
        } else {
            print("Entro al if antes del json para escribir el role")
        }
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

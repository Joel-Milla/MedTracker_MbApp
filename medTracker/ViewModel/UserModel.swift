//
//  UserModel.swift
//  medTracker
//
//  Created by Alumno on 17/11/23.
//

import Foundation
import FirebaseAuth

/**********************
 This class contains all the information about the user.
 **********************************/
@MainActor
class UserModel: ObservableObject {
    @Published var user = User() {
        didSet {
            saveUserData()
        }
    }
    let repository = Repository() // Variable to call the functions inside the repository
    private let auth = Auth.auth()
    
    /**********************
     Important initialization methods
     **********************************/
    init() {
        if let datosRecuperados = try? Data.init(contentsOf: HelperFunctions.filePath("User.JSON")) {
            if let datosDecodificados = try? JSONDecoder().decode(User.self, from: datosRecuperados) {
                user = datosDecodificados
                return
            }
        }
        //If there is no info in JSON, fetdh
        fetchUser()
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Save the information of the user
    func saveUserData() {
        HelperFunctions.write(self.user, inPath: "User.JSON")
    }
    
    // The functions returns a closure that is used to write information in firebase
    func makeCreateAction() -> ProfileView.CreateAction {
        return { [weak self] user in
            try await self?.repository.createUser(user)
        }
    }
    
    // The functions returns a closure that is used to write information in firebase
    func writePatient() -> AddDoctorView.WritePatient {
        return { [weak self] email, user in
            try await self?.repository.writePatient(email, user)
        }
    }
    
    // Delete a doctor from the list
    func makeDeleteAction() -> AddDoctorView.DeleteAction {
        return { [weak self] emailDoc in
            try await self?.repository.delete(emailDoc)
        }
    }
    
    // Fetch user information from the database and save them on the users list.
    func fetchUser() {
        Task {
            do {
                if let firebaseUserName = auth.currentUser?.displayName {
                    self.user.nombreCompleto = firebaseUserName
                } else {
                    user = try await self.repository.fetchUser()
                }
            } catch {
                print("[UserModel] Cannot fetch posts: \(error)")
                // If user is not found in the repository, try to get the name from Firebase
            }
        }
    }
}


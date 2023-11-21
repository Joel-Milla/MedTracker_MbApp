//
//  UserModel.swift
//  medTracker
//
//  Created by Alumno on 17/11/23.
//

import Foundation

/**********************
 This class contains all the information about the user.
 **********************************/
class UserModel: ObservableObject {
    @Published var user = User() {
        didSet {
            HelperFunctions.write(self.user, inPath: "User.JSON")
        }
    }
    let repository = Repository() // Variable to call the functions inside the repository

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
    
    // The functions returns a closure that is used to write information in firebase
    func makeCreateAction() -> ProfileView.CreateAction {
        return { [weak self] user in
            try await self?.repository.createUser(user)
        }
    }
    
    // Fetch user information from the database and save them on the users list.
    func fetchUser() {
        Task {
            do {
                user = try await self.repository.fetchUser()
            } catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
            }
        }
    }
}


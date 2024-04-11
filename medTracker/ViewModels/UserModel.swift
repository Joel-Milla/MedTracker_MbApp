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
    let repository: Repository // Variable to call the functions inside the repository
    private let auth = Auth.auth()
    
    /**********************
     Important initialization methods
     **********************************/
    private var usersURL: URL {
        do {
            let documentsDirectory = try HelperFunctions.filePath("user")
            return documentsDirectory
        }
        catch {
            fatalError("[UserModel] An error occurred while getting the url of the user: \(error)")
        }
    }

    init(repository: Repository) {
        self.repository = repository
        // Try to get information from fileManager. if it doesnt exist, bring it from fetch users.
        if let decodedData = HelperFunctions.loadData(in: usersURL, as: User.self) {
            self.user = decodedData
        } else {
            //If there is no info in JSON, fetch
            fetchUser()
            
        }
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Return a formViewModel that handles the creation of a new user
    func updateUserViewModel(for user: User) -> FormViewModel<User> {
        return FormViewModel(initialValue: User(user: user)) { [weak self] user in
            let (hasError, message) = user.validateInput()
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else {
                self?.user = user
                try await self?.repository.createUser(user) // use function in the repository to create/update the user
            }
        }
    }
    
    
    // Save the information of the user
    func saveUserData() {
        HelperFunctions.write(self.user, inPath: usersURL)
    }
    
    // The functions returns a closure that is used to write information in firebase
//    func makeCreateAction() -> ProfileView.CreateAction {
//        return { [weak self] user in
//            try await self?.repository.createUser(user)
//        }
//    }
    
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
                user = try await self.repository.fetchUser()    
            } catch {
                customPrint("[UserModel] Cannot fetch user: \(error)")
                // If user is not found in the repository, try to get the name from Firebase
            }
        }
    }
}


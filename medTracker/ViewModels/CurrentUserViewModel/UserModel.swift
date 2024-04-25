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
@dynamicMemberLookup // allows to shortcut the getting of properties inside user by utilizing the subscript

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
    // Function to create a class that manages the creation/deletion of a new doctor
    func createAddDoctorViewModel() -> DoctorsViewModel {
        // Action to perform when trying to add a new doctor
        let addDoctorAction = { [weak self] (emailDoctor: String) in
            let emailDoctor = emailDoctor.lowercased()
            let (hasError, message) = self?.user.validateAddingDoctor(from: emailDoctor) ?? (false, "")
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else {
                // Handle error when the email doctor is not Doctor
                let rol = try await HelperFunctions.fetchUserRole(email: emailDoctor)
                if (rol != "Doctor") {
                    throw HelperFunctions.ErrorType.general("El email no es valido.")
                }
                
                // If everything is okay to this point, then save the data
                self?.user.doctors.append(emailDoctor)
                try await self?.repository.updateDoctorsArray(self?.user.doctors ?? []) // Update the doctors array of the user on firebase
                try await self?.repository.writePatientInfo(emailDoctor, self?.user) // write the patient data on the section of the doctor
            }
        }
        
        // Remove doctor from user array and delete all patient/doctor information releated to this
        let deleteAction = { [weak self] (indicesToRemove: IndexSet) in
            // Get the emails of the doctors to remove by iterating through the indices and remove the patient info from firebase
            for index in indicesToRemove {
                let email = self?.user.doctors[index] ?? "Unknown email"
                try await self?.repository.removePatientInfo(at: email)
            }
            // Remove the emails from the current user array
            self?.user.doctors.remove(atOffsets: indicesToRemove)
            // Update the doctors array of the user
            try await self?.repository.updateDoctorsArray(self?.user.doctors ?? []) // Update the doctors array of the user on firebase
        }
        return DoctorsViewModel(doctors: self.user.doctors , newDoctor: "", addDoctorAction: addDoctorAction, deleteDoctorAction: deleteAction)
    }
    
    // Return a formViewModel that handles the creation of a new user
    func updateUserViewModel(for user: User) -> FormViewModel<User> {
        return FormViewModel(initialValue: User(user: user)) { [weak self] user in
            let (hasError, message) = user.validateUpdatingProfile()
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
    
    // Allows to get the properties inside the User by directly calling them from UserModel.
    // E.g. let userViewModel = UserModel(); print(userModel.name) -> 'Joel'... This is possible to do thanks to subscript to avoid doing: userModel.user.name
    subscript<T>(dynamicMember keyPath: KeyPath<User, T>) -> T {
        user[keyPath: keyPath]
    }
}


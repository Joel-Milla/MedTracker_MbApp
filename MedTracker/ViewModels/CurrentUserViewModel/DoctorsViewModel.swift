//
//  AddDoctorViewModel.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 10/04/24.
//

import Foundation

@MainActor
class DoctorsViewModel: ObservableObject {
    typealias AddDoctorAction = (String) async throws -> Void
    typealias DeleteDoctorAction = (IndexSet) async throws -> Void
    
    // Variables that will hold the values to show and manage the view, and to manage
    @Published var doctors: [String] // Array of doctors of the user
    @Published var newDoctor: String // Text to contain the email to add
    @Published var error: Error?
    @Published var state: HelperFunctions.State = .idle // state of the request.
    
    // Possible actions to perform
    private let addDoctorAction: AddDoctorAction
    private let deleteDoctorAction: DeleteDoctorAction
    
    // Initailizer when creating the object
    init(doctors: [String], newDoctor: String, error: Error? = nil, addDoctorAction: @escaping AddDoctorAction, deleteDoctorAction: @escaping DeleteDoctorAction) {
        self.doctors = doctors
        self.newDoctor = newDoctor
        self.error = error
        self.addDoctorAction = addDoctorAction
        self.deleteDoctorAction = deleteDoctorAction
    }
    
    // Function that handles adding a doctor
    nonisolated func addDoctor() {
        // Use task to avoid adding an 'async' keyword to this funtion
        Task {
            await handleAddDoctor()
        }
    }
    
    // Function that handles removing a doctor
    nonisolated func removeDoctor(at indicesToRemove: IndexSet) {
        // Use task to avoid adding an 'async' keyword to this funtion
        Task {
            await handleRemoveDoctor(at: indicesToRemove)
        }
    }

    // Function call to add a doctor in firebase
    private func handleAddDoctor() async {
        state = .isLoading
        do {
            try await addDoctorAction(newDoctor)
            state = .successfullyCompleted
        } catch {
            customPrint("[AddDoctorViewModel] Cannot submit: \(error)")
            self.error = error
            state = .idle
        }
    }
    
    // Function call to remove a doctor in firebase
    private func handleRemoveDoctor(at indicesToRemove: IndexSet) async {
        state = .isLoading
        do {
            try await deleteDoctorAction(indicesToRemove)
            state = .successfullyCompleted
        } catch {
            customPrint("[AddDoctorViewModel] Cannot submit: \(error)")
            self.error = error
            state = .idle
        }
    }
}

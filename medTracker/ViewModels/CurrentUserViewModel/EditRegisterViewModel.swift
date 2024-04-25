//
//  EditRegisterViewModel.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/04/24.
//

import Foundation

@MainActor
@dynamicMemberLookup
class EditRegisterViewModel: ObservableObject {
    typealias DeleteRegistersAction = (IndexSet) async throws -> Void
    
    // Variables that will hold the values to show and manage the view, and to manage
    let symptom: Symptom
    @Published var registers: [Register] // Array of doctors of the user
    @Published var error: Error?
    @Published var state: HelperFunctions.State = .idle // state of the request.
    
    // Possible actions to perform
    private let deleteRegistersAction: DeleteRegistersAction
    
    // Initailizer when creating the object
    init(symptom: Symptom, registers: [Register], error: Error? = nil, deleteRegistersAction: @escaping DeleteRegistersAction) {
        self.symptom = symptom
        self.registers = registers
        self.error = error
        self.deleteRegistersAction = deleteRegistersAction
    }
    
    // Helper function to create request to firebase to create user.
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Symptom, T>) -> T {
        get { symptom[keyPath: keyPath] }
    }
    
    // Function that handles removing registers
    nonisolated func removeRegisters(at indicesToRemove: IndexSet) {
        // Use task to avoid adding an 'async' keyword to this funtion
        Task {
            await handleRemoveRegisters(at: indicesToRemove)
        }
    }
    
    // Function call to remove a doctor in firebase
    private func handleRemoveRegisters(at indicesToRemove: IndexSet) async {
        state = .isLoading
        do {
            try await deleteRegistersAction(indicesToRemove)
            state = .successfullyCompleted
        } catch {
            customPrint("[EditRegisterViewModel] Cannot submit: \(error)")
            self.error = error
            state = .idle
        }
    }
}

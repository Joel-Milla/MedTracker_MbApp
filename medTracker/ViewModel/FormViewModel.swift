//
//  FormViewModel.swift
//  medTracker
//
//  Created by Alumno on 19/11/23.
//

import Foundation

/**********************
 This class contains all the data that helps to create a new user.
 **********************************/

@MainActor
@dynamicMemberLookup
class FormViewModel<Value>: ObservableObject {
    @Published var value: Value
    @Published var error: Error?
    @Published var state: State = .idle // state of the request.
    
    typealias Action = (Value) async throws -> Void
    private let action: Action //closure of type action.
    
    /**********************
     Important initialization methods
     **********************************/
    init(initialValue: Value, action: @escaping Action) {
        self.value = initialValue
        self.action = action
    }
    
    enum State {
        case idle
        case isLoading
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Helper function to create request to firebase to create user.
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }
    
    // Function that makes the request to database to create user.
    nonisolated func submit() {
        Task {
            await handleSubmit()
        }
    }
    
    // function that handles the request and catches the error.
    private func handleSubmit() async {
        state = .isLoading
        do {
            try await action(value)
        } catch {
            print("[FormViewModel] Cannot submit: \(error)")
            self.error = error
        }
        state = .idle
    }
}

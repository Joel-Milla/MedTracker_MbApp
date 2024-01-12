//
//  PatientList.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

import Foundation

/**********************
 This class contains all the patients of a doctor.
 **********************************/
@MainActor
class PatientList : ObservableObject {
    @Published var patientsList = [Patient]()
    @Published var state: State = .isLoading //State of the patients array
    let repository: Repository // Variable to call the functions inside the repository
    
    /**********************
     Important initialization methods
     **********************************/
    init(repository: Repository) {
        self.repository = repository
        //Fetch patients, so it loads every time
        fetchPatients()
    }
    
    enum State {
        case complete
        case isLoading
        case isEmpty
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Fetch patients from the database and save them on the patients list.
    func fetchPatients() {
        state = .isLoading
        Task {
            do {
                patientsList = try await self.repository.fetchPatients()
                state = patientsList.isEmpty ? .isEmpty : .complete
            } catch {
                print("[PatientsList] Cannot fetch patients: \(error)")
            }
        }
    }
}

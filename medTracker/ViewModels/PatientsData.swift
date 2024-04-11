//
//  PatientsData.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

import Foundation
import SwiftUI

/**********************
 This class contains all the data of the patients that the doctor selects
 **********************************/
class PatientsData : ObservableObject {
    @Published var patient: Patient
    @Published var symptoms = [Symptom]()
    @Published var registers = [Register]()
    @Published var state: State = .isLoading //State of the symptoms array
    let repository: Repository // Variable to call the functions inside the repository
    
    /**********************
     Important initialization methods
     **********************************/
    init(patient: Patient, repository: Repository) {
        self.repository = repository
        self.patient = patient
        
        fetchPatientsData()
        // For testing, the next function can be used for dummy data.
        //symptoms = getDefaultSymptoms()
    }
    
    enum State {
        case complete
        case isLoading
    }
    
    /**********************
     Helper functions
     **********************************/
    // Fetch patients data based on an email.
    func fetchPatientsData() {
        state = .isLoading
        Task {
            do {
                symptoms = try await self.repository.fetchSymptomsPatient(patient.email)
                registers = try await self.repository.fetchRegistersPatient(patient.email)
            } catch {
                customPrint("[PatientsData] Cannot fetch patients data: \(error)")
            }
        }
        state = .complete
    }
}


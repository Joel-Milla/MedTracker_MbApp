//
//  Repository.swift
//  medTracker
//
//  Created by Alumno on 17/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/**********************
 This struct contains helper functions to make the connection to the database (firebase)
 **********************************/

struct Repository {
    // Variables to make the connection to firebase.
    private var userReference = Firestore.firestore().collection("Users")
    private var doctorReference = Firestore.firestore().collection("Doctors-Patients")
    private var rolesReference = Firestore.firestore().collection("Roles")
    let user: User

    // Variables that hold the reference to the collections inside the user.
    private var symptomReference: CollectionReference {
        let userDocument = userReference.document(user.email)
        return userDocument.collection("symptoms")
    }
    private var registerReference: CollectionReference {
        let userDocument = userReference.document(user.email)
        return userDocument.collection("registers")
    }
    
    /**********************
     Important initialization methods
     **********************************/
    init(user: User) {
        self.user = user
    }
    
    /**********************
     Helper functions
     **********************************/
    // Function to edit a symptom in the database (could be writing a new symptom or updating it).
    func editSymptom(_ symptom: Symptom) async throws {
        let document = symptomReference.document(symptom.id.uuidString)
        try await document.setData(from: symptom)
    }

    
    // Function to write a symptom in database.
    func deleteSymptom(_ symptom: Symptom) async throws {
        let document = symptomReference.document(symptom.id.uuidString)
        try await document.delete()
    }
    
    // Function to fetch all the symptoms in firebase
    func fetchSymptoms() async throws -> [String: Symptom] {
        let symptomList = try await symptomReference
            .getDocuments(as: Symptom.self)
        var symptoms: [String: Symptom] = [:]
        for symptom in symptomList {
            symptoms[symptom.id.uuidString] = symptom
        }
        return symptoms
    }
    
    // Function to write a register in database.
    func createRegister(_ register: Register) async throws {
        let document = registerReference.document(register.id.uuidString)
        try await document.setData(from: register)
    }
    
    // Function to delete a register
    func deleteRegister(_ register: Register) async throws {
        let document = registerReference.document(register.id.uuidString)
        try await document.delete()
    }
    
    // Function to delete a register by id
    func deleteRegisterByID(_ id: UUID) async throws {
        let document = registerReference.document(id.uuidString)
        try await document.delete()
    }
    
    // Function to obtain the registers of the database in ascending order (old to new)
    func fetchRegisters() async throws -> [String: [Register]] {
        let registerList = try await registerReference
            .order(by: "date", descending: false)
            .getDocuments(as: Register.self)
        var registers: [String: [Register]] = [:]
        for register in registerList {
            let idSymptom = register.idSymptom
            // Check if the key has an empty array
            if (registers[idSymptom] == nil) {
                registers[idSymptom] = []
            }
            // Add the register
            registers[idSymptom]?.append(register)
        }
        return registers
    }
    
    // Function to write a user in database.
    func createUser(_ user: User) async throws {
        let document = userReference.document(user.email)
        try await document.setData(from: user)
    }
    
    // Functin to obtain the user info that exist on database.
    func fetchUser() async throws -> User {
        let userDocument = userReference.document(user.email)
        let user = try await userDocument.getDocument(as: User.self)
        return user
    }
    
    // Function to update only the array of doctors in the database
    func updateDoctorsArray(_ doctors: [String]) async throws {
        let document = userReference.document(user.email)
        // Update the doctors of the user by only modifying that specific key
        try await document.setData(["doctors": doctors], merge: true)
    }
    
    // Function to write own name as a document in doctors collection
    func writePatientInfo(_ doctorsEmail: String, _ user: User?) async throws {
        let user = user ?? self.user
        let docDocument = doctorReference.document(doctorsEmail)
        let patientsReference = docDocument.collection("patients")
        let document = patientsReference.document(user.email)
        try await document.setData([
            "name": user.name,
            "email": user.email,
            "phone": user.phone
        ])
    }
    
    // Delete an email from the doctor
    func removePatientInfo(at docEmail: String) async throws {
        let doctorData = doctorReference.document(docEmail)
        let patientReference = doctorData.collection("patients")
        let document = patientReference.document(user.email)
        try await document.delete()
    }
    
    // Function to fetch all the patients of a doctor.
    func fetchPatients() async throws -> [Patient] {
        let docDocument = doctorReference.document(user.email)
        let patientsReference = docDocument.collection("patients")
        let patients = try await patientsReference
            .getDocuments(as: Patient.self)
        return patients
    }
    
    // Function to fetch all the symptoms in firebase of a patient.
    func fetchSymptomsPatient(_ email: String) async throws -> [Symptom] {
        let userDocument = userReference.document(email)
        let collectionSymptoms = userDocument.collection("symptoms")
        let symptoms = try await collectionSymptoms
            .getDocuments(as: Symptom.self)
        return symptoms
    }
    
    // Functin to obtain the registers that exist on database of the patient.
    func fetchRegistersPatient(_ email: String) async throws -> [Register] {
        let userDocument = userReference.document(email)
        let collectionRegisters = userDocument.collection("registers")
        let registers = try await collectionRegisters
            .getDocuments(as: Register.self)
        return registers
    }
}

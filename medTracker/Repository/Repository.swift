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
    // Function to write a symptom in database.
    func createSymptom(_ symptom: Symptom) async throws {
        let document = symptomReference.document(String(symptom.id))
        try await document.setData(from: symptom)
    }
    
    // Function to write a symptom in database.
    func deleteSymptom(_ symptom: Symptom) async throws {
        let document = symptomReference.document(String(symptom.id))
        try await document.delete()
    }
    
    // Function to fetch all the symptoms in firebase
    func fetchSymptoms() async throws -> [Symptom] {
        let symptoms = try await symptomReference
            .order(by: "id", descending: false)
            .getDocuments(as: Symptom.self)
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
    
    // Function to obtain the registers of the database
    func fetchRegisters() async throws -> [Register] {
        let registers = try await registerReference
            .order(by: "idSymptom", descending: false)
            .getDocuments(as: Register.self)
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
    
    // Function to write own name as a document in doctors collection
    func writePatient(_ docEmail: String, _ user: User) async throws {
        let docDocument = doctorReference.document(docEmail)
        let patientsReference = docDocument.collection("patients")
        let document = patientsReference.document(user.email)
        try await document.setData([
            "name": user.nombreCompleto,
            "email": user.email
        ])
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
    
    // Delete an email from the doctor
    func delete(_ docEmail: String) async throws {
        let doctorData = doctorReference.document(docEmail)
        let patientReference = doctorData.collection("patients")
        let document = patientReference.document(user.email)
        try await document.delete()
    }
}

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
    private var doctorReference = Firestore.firestore().collection("Doctors")
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
    
    // Function to fetch all the symptoms in firebase.
    func fetchSymptoms() async throws -> [Symptom] {
        let snapshot = try await symptomReference
            .order(by: "id", descending: false)
            .getDocuments()
        // Convert the returning documents into the class Symptom
        return snapshot.documents.compactMap { document in
            try! document.data(as: Symptom.self)
        }
    }
    
    // Function to write a register in database.
    func createRegister(_ register: Register) async throws {
        let document = registerReference.document(UUID().uuidString)
        try await document.setData(from: register)
    }
    
    // Functin to obtain the registers that exist on database.
    func fetchRegisters() async throws -> [Register] {
        let snapshot = try await registerReference
            .order(by: "idSymptom", descending: false)
            .getDocuments()
        // Convert the returning documents into the class Register
        return snapshot.documents.compactMap { document in
            try! document.data(as: Register.self)
        }
    }
    
    // Function to write a user in database.
    func createUser(_ user: User) async throws {
        let document = userReference.document(user.email)
        try await document.setData(from: user)
    }
    
    // Functin to obtain the user info that exist on database.
    func fetchUser() async throws -> User {
        let documentReference = userReference.document(user.email)
        let documentSnapshot = try await documentReference.getDocument()
        
        // Try to decode the document data into a User object
        do {
            let userData = try documentSnapshot.data(as: User.self)
            return userData
        } catch {
            // Handle the error if decoding fails
            throw NSError(domain: "DataDecodingError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user data: \(error.localizedDescription)"])
        }
    }
    
    // Function to write own name as a document in doctors collection
    func writePatient(_ docEmail: String, _ user: User) async throws {
        let doctorData = doctorReference.document(docEmail)
        let patientReference = doctorData.collection("patients")
        let document = patientReference.document(user.email)
        try await document.setData([
            "name": user.nombreCompleto,
            "email": "test_mail"
        ])
    }
    
    // Function to fetch all the patients of a doctor.
    func fetchPatients() async throws -> [Patient] {
        let snapshot = try await doctorReference.getDocuments()
        // Convert the returning documents into the class Patient
        return snapshot.documents.compactMap { document in
            try! document.data(as: Patient.self)
        }
    }
    
    // Function to fetch all the symptoms in firebase of a patient.
    func fetchSymptomsPatient(_ email: String) async throws -> [Symptom] {
        let userDocument = userReference.document(email)
        let collectionSymptoms = userDocument.collection("symptoms")
        let snapshot = try await collectionSymptoms
            .order(by: "idSymptom", descending: false)
            .getDocuments()
        // Convert the returning documents into the class Register
        return snapshot.documents.compactMap { document in
            try! document.data(as: Symptom.self)
        }
    }
    
    // Functin to obtain the registers that exist on database of the patient.
    func fetchRegistersPatient(_ email: String) async throws -> [Register] {
        let userDocument = userReference.document(email)
        let collectionRegisters = userDocument.collection("registers")
        let snapshot = try await collectionRegisters
            .order(by: "idSymptom", descending: false)
            .getDocuments()
        // Convert the returning documents into the class Register
        return snapshot.documents.compactMap { document in
            try! document.data(as: Register.self)
        }
    }
    
    // Delete an email from the doctor
    func delete(_ docEmail: String) async throws {
        let doctorData = doctorReference.document(docEmail)
        let patientReference = doctorData.collection("patients")
        let document = patientReference.document(user.email)
        try await document.delete()
    }
}

// This method is to not show an error for some of the methods above.
private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Method only throws if there’s an encoding error, which indicates a problem with our model.
            // We handled this with a force try, while all other errors are passed to the completion handler.
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

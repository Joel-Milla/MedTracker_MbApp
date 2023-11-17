//
//  SymptomRepository.swift
//  medTracker
//
//  Created by Alumno on 17/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SymptomRespository {
    static let symptomRepository = Firestore.firestore().collection("symptoms")
    
    static func create(_ symptom: Symptom) async throws {
        let document = symptomRepository.document(String(symptom.id))
        try await document.setData(from: symptom)
    }
}

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

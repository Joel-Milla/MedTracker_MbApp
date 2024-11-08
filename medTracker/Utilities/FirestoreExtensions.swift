//
//  Firestore+Extensions.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/01/24.
//

import Foundation
import FirebaseFirestore

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: type)
        }
    }
}

// This method is to not show an error for some of the methods above.
extension DocumentReference {
    func getDocument<T: Decodable>(as type: T.Type) async throws -> T {
        let snapshot = try await getDocument()
        return try snapshot.data(as: type)
    }

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

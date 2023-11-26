//
//  HelperFunctions.swift
//  medTracker
//
//  Created by Alumno on 20/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/**********************
 This class will contain all the functions that are needed multiple times among all the project.
 **********************************/

class HelperFunctions {
    // This function returns a url inside sandbox based on the "path" variable that is being passed.
    static func filePath(_ path: String) -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent(path)
        return pathArchivo
    }
    // The function write(), writes the "value" being passed into the "file" passed.
    // Uses the t:encodable to accept any type of value.
    static func write<T: Encodable>(_ value: T, inPath file: String) {
        DispatchQueue.main.async {
            if let codificado = try? JSONEncoder().encode(value) {
                try? codificado.write(to: filePath(file)) //writes the value passed into the file passed.
            }
        }
    }
    
    // Fetch users role from firestore
    static func fetchUserRole(email: String) async throws -> String {
        let db = Firestore.firestore()
        
        guard !email.isEmpty else {
            throw NSError(domain: "InvalidEmailError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Email is empty"])
        }
        
        
        let document = try await db.collection("Roles").document(email).getDocument()
        let role = document.data()?["role"] as? String ?? "Unknown"
        return role
    }
}

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
    static func filePath(_ path: String) throws -> URL {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let pathArchivo = url.appendingPathComponent(path)
        return pathArchivo
    }

    // The function write(), writes the "value" being passed into the "file" passed.
    // Uses the t:encodable to accept any type of value.
    static func write<T: Encodable>(_ value: T, inPath file: URL) {
        do {
            let encodedData = try JSONEncoder().encode(value)
            try encodedData.write(to: file)
        }
        catch {
            fatalError("An error occured while saving the recipes: \(error)")
        }
    }

    // Function that loads data and sents it back
    static func loadData<T: Codable>(in inPath: URL, as type: T.Type) -> T? {
        guard let data = try? Data(contentsOf: inPath) else { return nil }
        do {
            let dataDecoded = try JSONDecoder().decode(type, from: data)
            return dataDecoded
        }
        catch {
            fatalError("[HelperFunctions] An error occurred while loading data of type [\(type)]: \(error)")
        }
    }
    
    // Fetch users role from firestore
    static func fetchUserRole(email: String) async throws -> String {
        let db = Firestore.firestore()
        
        let document = try await db.collection("Roles").document(email).getDocument()
        let role = document.data()?["role"] as? String ?? "[HelperFunctions] Rol desconocido"
        return role
    }
}

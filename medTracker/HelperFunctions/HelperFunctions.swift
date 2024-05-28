//
//  HelperFunctions.swift
//  medTracker
//
//  Created by Alumno on 20/11/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

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
            fatalError("[HelperFunctions] Error while writing a file in \(file): Error \(error)")
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
    
    // This dateRange is used in the datePickers so the user is limited by selecting only dates of the 120 years prior to the current date
    static let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .year, value: -120, to: Date())!
        let end = Date()
        return start...end
    }()
    
    // Function that when receives a value of number (like int/float/double) it returns the image that corresponds to that value. 
    static func getImage<T: Numeric & Comparable>(of value: T) -> Image {
        var imageName: String

        switch value {
        case 0..<20:
            imageName = "sadder_face_noBG"
        case 20..<40:
            imageName = "sad_face_noBG"
        case 40..<60:
            imageName = "normal_face_noBG"
        case 60..<80:
            imageName = "happy_face_noBG"
        case 80...:
            imageName = "happier_face_noBG"
        default:
            imageName = ""
        }

        return Image(imageName)
    }
    
    // Function receives an error from authentication service and returns the error localized
    static func handleFirebaseAuthError(code error: Error) throws {
        guard let error = error as NSError? else { 
            throw HelperFunctions.ErrorType.general("Hubo un error con la informaciòn")
        }
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            throw HelperFunctions.ErrorType.general("Hubo un error con la informaciòn")
        }
        switch(errorCode) {
        case .networkError:
            throw HelperFunctions.ErrorType.networkError
        case .invalidEmail:
            throw HelperFunctions.ErrorType.invalidEmail
        case .weakPassword:
            throw HelperFunctions.ErrorType.weakPassword
        case .emailAlreadyInUse:
            throw HelperFunctions.ErrorType.emailAlreadyInUse
        case .invalidCredential:
            throw HelperFunctions.ErrorType.invalidCredentials
        default:
            throw HelperFunctions.ErrorType.general("Ocurrio un error, por favor de intentarlo nuevamente")
        }
    }
    
    // Function that handles an error when making a request to Firestore
    static func handleFirestoreError(code error: Error) throws {
        throw HelperFunctions.ErrorType.general("Hubo un error, por favor de intentarlo nuevamente")
    }
    
    // Special enum to throw tell that the input is not valid and with the possibility to add a message to print
    enum ErrorType: Error, LocalizedError {
        // General errors and modifiable errors
        case networkError
        case general(String) // Error for a case not handle on the other errors.
        case invalidInput(String) // Error when the input of the user is invalid
        // Error throwns when creating an account
        case invalidEmail
        case weakPassword
        case emailAlreadyInUse
        case operationNotAllowed
        // Error thrown when signin in
        case invalidCredentials
        
        
        var errorDescription: String? {
            switch self {
            case .networkError:
                return "Hubo un problema de conexión, intentalo nuevamente."
            case .general(let message):
                return message
            case .invalidInput(let message):
                return message
            case .invalidEmail: // for creating an account and when loggin in
                return "La dirección de correo electrónico está mal formada."
            case .weakPassword:
                return "La contraseña debe de tener al menos 6 caracteres."
            case .emailAlreadyInUse:
                return "El correo electrónico ya está en uso."
            case .operationNotAllowed:
                return "La operación no está permitida."
            case .invalidCredentials:
                return "El mail o la contraseña son incorrectos."
            }
        }
    }
    
    // Enum for the state of the request
    enum State {
        case idle
        case isLoading
        case successfullyCompleted
    }
    
    // UUIDs that work for recognizing different symptoms
    static let zeroUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")! // UUID for bloodPressureSymptom
    static let zeroOneOneUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")! // UUID for SYSTOLIC register
    static let zeroOneUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")! // UUID for DIASTOLIC register
}
    


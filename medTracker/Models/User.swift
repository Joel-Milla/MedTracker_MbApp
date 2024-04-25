//
//  Usuario.swift
//  medTracker
//
//  Created by Alumno on 04/11/23.
//

import Foundation

struct User : Codable, Hashable {
    var id: String = ""
    var rol: String = ""
    var email: String = ""
    var phone : String // Unique identifier
    var name : String
    var clinicalHistory : String
    var sex: String
    var birthdate: Date
    var height : String
    var doctors: [String]
    
    var formattedDateOfBirth: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Set the date format as needed
            return dateFormatter.string(from: birthdate)
        }
    }
    
    var formattedClinicalHistory: String {
        get {
            return self.clinicalHistory
        }
        set {
            if newValue.count > 1000 {
                self.clinicalHistory = String(newValue.prefix(1000))
            } else {
                self.clinicalHistory = newValue
            }
        }
    }
    
    // Main init
    init(phone: String, name: String, clinicalHistory: String, sex: String, birthdate: Date, height: String, doctors: [String]) {
        self.phone = phone
        self.name = name
        self.clinicalHistory = clinicalHistory
        self.sex = sex
        self.birthdate = birthdate
        self.height = height
        self.doctors = doctors
    }
    
    // Init for creating empty objects
    init() {
        self.phone = ""
        self.name = ""
        self.clinicalHistory = ""
        self.sex = ""
        self.birthdate = Date()
        self.height = ""
        self.doctors = []
    }
    
    // Initalizer for updating a current user in profile view when creating the FormViewModel for initial state
    init(user: User) {
        self = user
    }
    
    // Init for the preview in mainView to work
    init(id: String, rol: String, email: String, phone: String, name: String, clinicalHistory: String, sex: String, birthdate: Date, height: String, doctors: [String]) {
        self.id = id
        self.rol = rol
        self.email = email
        self.phone = phone
        self.name = name
        self.clinicalHistory = clinicalHistory
        self.sex = sex
        self.birthdate = birthdate
        self.height = height
        self.doctors = doctors
    }
    
    // This function is used in ProfileView to validte if there is any error while updating user data
    func validateUpdatingProfile() -> (Bool, String) {
        if let height = Double(self.height) {
            if (self.phone == "" || self.height == "" || self.sex == "") {
                return (true, "Datos faltantes. Por favor llena todos los campos obligatorios.")
            } else if (height < 0.20 || height > 2.5) {
                return (true, "Estatura inválida. Favor de ingresar una estatura válida en metros.")
            } else if (self.birthdate == Date.now || self.birthdate > Date.now || (getYear(date: Date.now) - getYear(date: self.birthdate) > 120)) {
                return (true, "Por favor ingresa una fecha válida.")
            } else if (self.sex == "-") {
                return (true, "Favor de elegir sexo.")
            }
        } else {
            return (true, "Estatura inválida. Favor de ingresar una estatura válida en metros.")
        }
        return (false, "")
    }
    
    // This function checks if it is possible to add an email doctor to the array of doctors
    func validateAddingDoctor(from emailDoctor: String) -> (Bool, String) {
        if (emailDoctor == "") {
            return (true, "El campo del email del doctor esta vacío")
        } else if (doctors.contains(emailDoctor)) {
            return (true, "Ya se estan compartiendo los datos a este email")
        }
        return (false, "")
    }
    func getYear(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return components.year ?? 0
    }
}

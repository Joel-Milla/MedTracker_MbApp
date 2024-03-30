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
    var telefono : String // Unique identifier
    var nombreCompleto : String
    var antecedentes : String
    var sexo: String
    var fechaNacimiento: Date
    var estatura : String
    var arregloDoctor: [String]
    
    var formattedDateOfBirth: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Set the date format as needed
            return dateFormatter.string(from: fechaNacimiento)
        }
    }
    
    var formattedAntecedentes: String {
        get {
            return self.antecedentes
        }
        set {
            if newValue.count > 1000 {
                self.antecedentes = String(newValue.prefix(1000))
            } else {
                self.antecedentes = newValue
            }
        }
    }
    
    // Main init
    init(telefono: String, nombre: String, antecedentes: String, sexo: String, fechaNacimiento: Date, estatura: String, arregloDoctor: [String]) {
        self.telefono = telefono
        self.nombreCompleto = nombre
        self.antecedentes = antecedentes
        self.sexo = sexo
        self.fechaNacimiento = fechaNacimiento
        self.estatura = estatura
        self.arregloDoctor = arregloDoctor
    }
    
    // Init for creating empty objects
    init() {
        self.telefono = ""
        self.nombreCompleto = ""
        self.antecedentes = ""
        self.sexo = ""
        self.fechaNacimiento = Date()
        self.estatura = ""
        self.arregloDoctor = []
    }
    
    // Init for the preview in mainView to work
    init(id: String, rol: String, email: String, telefono: String, nombreCompleto: String, antecedentes: String, sexo: String, fechaNacimiento: Date, estatura: String, arregloDoctor: [String]) {
        self.id = id
        self.rol = rol
        self.email = email
        self.telefono = telefono
        self.nombreCompleto = nombreCompleto
        self.antecedentes = antecedentes
        self.sexo = sexo
        self.fechaNacimiento = fechaNacimiento
        self.estatura = estatura
        self.arregloDoctor = arregloDoctor
    }
    
    func error() -> (Bool, String) {
        if let height = Double(self.estatura) {
            if (self.telefono == "" || self.estatura == "" || self.sexo == "") {
                return (true, "Datos faltantes. Por favor llena todos los campos obligatorios.")
            } else if (height < 0.20 || height > 2.5) {
                return (true, "Estatura inválida. Favor de ingresar una estatura válida en metros.")
            } else if (self.fechaNacimiento == Date.now || self.fechaNacimiento > Date.now || (getYear(date: Date.now) - getYear(date: self.fechaNacimiento) > 120)) {
                return (true, "Por favor ingresa una fecha válida.")
            } else if (self.sexo == "-") {
                return (true, "Favor de elegir sexo.")
            }
        } else {
            return (true, "Estatura inválida. Favor de ingresar una estatura válida en metros.")
        }
        return (false, "")
    }
    
    func getYear(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return components.year ?? 0
    }
}

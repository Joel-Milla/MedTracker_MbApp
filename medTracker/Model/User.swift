//
//  Usuario.swift
//  medTracker
//
//  Created by Alumno on 04/11/23.
//

import Foundation

struct User : Codable, Hashable {
    var telefono : String // Unique identifier
    var nombre : String
    var apellidoPaterno : String
    var apellidoMaterno : String
    var antecedentes : String
    var estatura : Double
    
    var estaturaString: String {
        get {
            if estatura == 0.0 {
                return String("")
            } else {
                return String(format: "%.2f", self.estatura)
            }
        }
        set {
            self.estatura = Double(newValue) ?? 0.0
        }
    }
    
    init() {
        self.telefono = ""
        self.nombre = ""
        self.apellidoPaterno = ""
        self.apellidoMaterno = ""
        self.antecedentes = ""
        self.estatura = 0.0
    }
    
    init(telefono: String, nombre: String, apellidoPaterno: String, apellidoMaterno: String, antecedentes: String, estatura: Double) {
        self.telefono = telefono
        self.nombre = nombre
        self.apellidoPaterno = apellidoPaterno
        self.apellidoMaterno = apellidoMaterno
        self.antecedentes = antecedentes
        self.estatura = estatura
    }
    
    func datosFaltantes() -> Bool {
        if (self.telefono == "" || self.nombre == "" || self.apellidoPaterno == "" || self.apellidoMaterno == "" || self.antecedentes == "" || self.estatura == 0.0) {
            return true
        }
        return false
    }
}

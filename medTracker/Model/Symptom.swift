//
//  DatosSalud.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 03/11/23.
//

import Foundation

struct Symptom : Codable, Hashable, Identifiable {
    var id = UUID()
    var nombre : String
    var icon : String
    var description : String
    var cuantitativo : Bool // True = Cuantitativo, False = Cualitativo
    var unidades  : String
    var activo : Bool
    var color : String
    var notificacion : String
    var fecha : Date = Date.now
    
    // Normal Init
    init(nombre: String, icon: String, description: String, cuantitativo: Bool, unidades: String, activo: Bool, color: String, notificacion : String) {
        self.nombre = nombre
        self.icon = icon
        self.description = description
        self.cuantitativo = cuantitativo
        self.unidades = unidades
        self.activo = activo
        self.color = color
        self.notificacion = notificacion
    }
    // Init for initializing a symptom with default values
    init() {
        self.init(nombre: "", icon: "heart", description: "", cuantitativo: true, unidades: "kg", activo: true, color: "#009C8C", notificacion : "")
    }
    
    // Function to validate if the necessary inputs are filled
    func validateInput() -> (Bool, String) {
        if (nombre == "") {
            return (true, "Datos faltantes. Por favor de poner un nombre al dato.")
        } else if (description == "") {
            return (true, "Datos faltantes. Por favor de poner una descripción al dato.")
        }
        return (false, "")
    }
    
}

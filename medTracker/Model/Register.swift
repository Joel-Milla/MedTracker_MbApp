//
//  Registrar.swift
//  medTracker
//
//  Created by Alumno on 08/11/23.
//

import Foundation

struct Register : Codable, Hashable, Identifiable {
    var id = UUID()
    var idSymptom : String
    var fecha : Date
    var cantidad : Float
    var notas : String
    var animate : Bool = false // Variable to animate the graph on the chartViews
    
    init(idSymptom: String, fecha: Date, cantidad: Float, notas: String) {
        self.idSymptom = idSymptom
        self.fecha = fecha
        self.cantidad = cantidad
        self.notas = notas
    }
    
    init(idSymptom: String) {
        self.init(idSymptom: idSymptom, fecha: Date.now, cantidad: 0.0, notas: "")
    }
    
    func returnString()->String{
        return "\(self.fecha), \(String(self.cantidad)), \(self.notas)"
    }
    
    // Function to validate if the register to create is valid
    func validateInput() -> (Bool, String) {
        // The number -1000.99 will mean that the value user inputted wasnt able to convert to string
        if (cantidad == -1000.99) {
            return (true, "Por favor de ingresar un dato valido.")
        }
        return (false, "")
    }
}

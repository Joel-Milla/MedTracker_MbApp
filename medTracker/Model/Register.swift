//
//  Registrar.swift
//  medTracker
//
//  Created by Alumno on 08/11/23.
//

import Foundation

struct Register : Codable, Hashable {
    var idSymptom : Int
    var fecha : Date
    var cantidad : Float
    var notas : String
    //var animacion : Bool
    
    init(idSymptom: Int, fecha: Date, cantidad: Float, notas: String) {
        self.idSymptom = idSymptom
        self.fecha = fecha
        self.cantidad = cantidad
        self.notas = notas
        //self.animacion = false
    }
    
    func returnString()->String{
        return "\(self.fecha), \(String(self.cantidad)), \(self.notas)"
    }
}

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
    var date : Date
    var amount : Float
    var notes : String
    var animate : Bool = false // Variable to animate the graph on the chartViews
    
    init(idSymptom: String, date: Date, amount: Float, notes: String) {
        self.idSymptom = idSymptom
        self.date = date
        self.amount = amount
        self.notes = notes
    }
    
    init(idSymptom: String) {
        self.init(idSymptom: idSymptom, date: Date.now, amount: 0.0, notes: "")
    }
    
    func returnString()->String{
        return "\(self.date), \(String(self.amount)), \(self.notes)"
    }
    
    // Function to validate if the register to create is valid
    func validateInput() -> (Bool, String) {
        // The number -1000.99 will mean that the value user inputted wasnt able to convert to string
        if (amount == -1000.99) {
            return (true, "Por favor de ingresar un dato valido.")
        }
        return (false, "")
    }
}



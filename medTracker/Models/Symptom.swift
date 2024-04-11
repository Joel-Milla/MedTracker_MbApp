//
//  DatosSalud.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 03/11/23.
//

import Foundation

struct Symptom : Codable, Hashable, Identifiable {
    var id = UUID()
    var name : String
    var icon : String
    var description : String
    var isQuantitative : Bool // True = Cuantitativo, False = Cualitativo
    var units  : String
    var isActive : Bool
    var color : String
    var notification : String
    var creationDate : Date = Date.now
    
    // Normal Init
    init(name: String, icon: String, description: String, isQuantitative: Bool, units: String, isActive: Bool, color: String, notification : String) {
        self.name = name
        self.icon = icon
        self.description = description
        self.isQuantitative = isQuantitative
        self.units = units
        self.isActive = isActive
        self.color = color
        self.notification = notification
    }
    // Init for initializing a symptom with default values
    init() {
        // Initial value for NotificationsView to render inside the notification
        self.init(name: "", icon: "heart", description: "", isQuantitative: true, units: "kg", isActive: true, color: "#009C8C", notification : "D#\(DateUtility.hourToString(Date.now))")
    }
    
    // Function to validate if the necessary inputs are filled
    func validateInput() -> (Bool, String) {
        if (name == "") {
            return (true, "Datos faltantes. Por favor de poner un nombre al dato.")
        } else if (description == "") {
            return (true, "Datos faltantes. Por favor de poner una descripción al dato.")
        }
        return (false, "")
    }
    
}

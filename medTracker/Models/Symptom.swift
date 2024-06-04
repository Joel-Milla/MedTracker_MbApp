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
    var isFavorite : Bool
    var color : String
    var notification : String
    var creationDate : Date = Date.now
    
    // Computed property that returns a string explaining the notifications that the user selected
    var notificationString: String {
        guard !notification.isEmpty else {
            return "No hay notificaciones programadas."
        }
        
        let elements = notification.components(separatedBy: "#")
        // Handle the three cases when it is daily, weekly, and monthly
        switch elements.first {
        case "D":
            if elements.count > 1 {
                let time = elements[1]
                return "Notificación diaria a las \(time) horas."
            }
        case "W":
            if elements.count > 2 {
                let daysCode = elements[1]
                if daysCode.isEmpty {
                    // Handle the case where no days were selected
                    return "No se seleccionaron días para la notificación semanal."
                }
                
                let time = elements[2]
                let days = daysCode.map { dayCode -> String in
                    switch dayCode {
                    case "L": return "lunes"
                    case "M": return "martes"
                    case "X": return "miércoles"
                    case "J": return "jueves"
                    case "V": return "viernes"
                    case "S": return "sábado"
                    case "D": return "domingo"
                    default: return ""
                    }
                }.joined(separator: ", ")
                
                return "Notificación semanal los días \(days) a las \(time) horas."
            }
        case "M":
            if elements.count > 1 {
                let dateTime = elements[1]
                
                // Attempt to parse the dateTime string into an actual Date object
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"  // Ensure your date format matches the expected format in `dateTime`
                
                if let date = dateFormatter.date(from: dateTime) {
                    // Create a more user-friendly dateFormatter for start date and recurring pattern
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "d 'de' MMMM 'a las' HH:mm 'horas'"  // e.g., "5 de marzo a las 14:00 horas"
                    startDateFormatter.locale = Locale(identifier: "es_ES")  // Spanish locale for full date and month names
                    
                    let recurringDateFormatter = DateFormatter()
                    recurringDateFormatter.dateFormat = "d 'de cada mes a las' HH:mm 'horas'"  // e.g., "5 de cada mes a las 14:00 horas"
                    recurringDateFormatter.locale = Locale(identifier: "es_ES")  // Ensure month names are in Spanish
                    
                    let formattedStartDate = startDateFormatter.string(from: date)
                    let formattedRecurringDate = recurringDateFormatter.string(from: date)
                    
                    return "Notificación mensual comienza el \(formattedStartDate) y se repetirá el \(formattedRecurringDate)."
                } else {
                    return "Fecha y hora proporcionadas no son válidas."
                }
            }
            
        default:
            break
        }
        
        return "Formato de notificación no reconocido."
    }
    
    // Normal Init
    init(name: String, icon: String, description: String, isQuantitative: Bool, units: String, isFavorite: Bool, color: String, notification : String) {
        self.name = name
        self.icon = icon
        self.description = description
        self.isQuantitative = isQuantitative
        self.units = units
        self.isFavorite = isFavorite
        self.color = color
        self.notification = notification
    }
    
    // Init for initializing a symptom with default values
    init() {
        // Initial value for NotificationsView to render inside the notification
        self.init(name: "", icon: "heart", description: "", isQuantitative: true, units: "kg", isFavorite: false, color: "#009C8C", notification : "")
    }
    
    // Init for initializing a symptom and setting the id. This is used on SymptomList when initializing the viewModel
    init(id: UUID, name: String, icon: String, description: String, isQuantitative: Bool, units: String, isFavorite: Bool, color: String, notification : String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.isQuantitative = isQuantitative
        self.units = units
        self.isFavorite = isFavorite
        self.color = color
        self.notification = notification
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

//
//  Notifications.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 25/11/23.
//

import Foundation
import SwiftUI

public func scheduleNotification(frecuencia: String, selectedDate: Date, selectedDayOfWeek: String, nombreSintoma: String) -> String  {
    let content = UNMutableNotificationContent()
    content.title = "MedTracker"
    content.subtitle = "Es hora de registrar \(nombreSintoma)"
    content.sound = UNNotificationSound.default
    
    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
    
    switch frecuencia {
    case "Todos los días":
        break // Utilizamos los valores del DatePicker directamente
    case "Cada semana":
        if let weekday = DateUtils.weekdayFromString(selectedDayOfWeek) {
            dateComponents.weekday = weekday
        }
    case "Una vez al mes":
        dateComponents.day = Calendar.current.component(.day, from: selectedDate)
    default:
        break
    }
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            customPrint("[Notifications] Error scheduling notification: \(error.localizedDescription)")
        } else {
            customPrint("[Notifications] Notification scheduled successfully!")
        }
    }
    return request.identifier
}

public func cancelNotification(withID notificationID: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
}

public func cancelAllNotification() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
}

//
//  NotificationManager.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 05/04/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager() // singleton - use this instance to manage
    private let notificationsKey = "Notifications" // The key to access user defaults notification
    
    // Instance to request the user to allow or deny notifications
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        // The requestAuth remember what the user selected, so it doesnt send multiple alerts many times
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            // if an error exists, print the error
            if let error = error {
                print("ERROR: ", error.localizedDescription)
            } else {
                print("SUCCESS ON SETTING NOTIFICATIONS")
            }
        }
    }
    
    func scheduleNotifications(_ codeNotification: String, _ symptom: Symptom) {
        // Remove all notifications, if any, of the symptom
        removeAllNotifications(for: symptom.id.uuidString)
        let symptomId = symptom.id.uuidString
        
        // Schedule the notifications
        let content = UNMutableNotificationContent()
        content.title = symptom.name
        content.subtitle = "Es hora de escribir tu registro!"
        // Can modify the sound and badge because that is requested on the options inside the requestAuthorization
        content.sound = .default
        content.badge = 1
        
        // Handle the multiple options of notifications
        let elements = codeNotification.components(separatedBy: "#")
        switch(elements[0]) {
        case "D": // If string starts with D, then format is D#hour. e.g: D#16:20
            let selectedHour = elements[1] // The string contains an hour like 20:18, so it convert to a date variable and saves it
            let time = selectedHour.components(separatedBy: ":")
            var dateComponents = DateComponents()
            dateComponents.hour = Int(time[0]) ?? 16
            dateComponents.minute = Int(time[1]) ?? 0
            
            // Trigger the notification
            notificationRequest(symptomId, dateComponents, content)

        case "W": // If string starts with W, then format is W#Days#hour. e.g: W#LMX#16:20 (which means that notifications are weekly, in days Lunes, Martes, Miercoles, at hour 16:20
            let weekDays: [String: Int] = [ "D": 1, "L": 2, "M": 3, "X": 4, "J": 5,"V": 6, "S": 7 ] // The variable holds the days of the week and which was selected
            // Set notifications
            let daysComponent = elements[1] // "LMX" for Monday, Tuesday, Wednesday
            let selectedHour = elements[2] // "16:20"
            let timeComponents = selectedHour.components(separatedBy: ":")
            let hour = Int(timeComponents[0]) ?? 16
            let minute = Int(timeComponents[1]) ?? 0
            
            for day in daysComponent {
                let keyDay = String(day) // Convert the character into a string to obtain the value in dictionary
                if let weekDay = weekDays[keyDay] {
                    // Obtain the week of the day the notification repeats and which hour
                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    dateComponents.weekday = weekDay
                    
                    // Trigger the notification
                    notificationRequest(symptomId, dateComponents, content)
                }
            }
        case "M": // If the string starts with M, then it will repeat at a specific hour and day. e.g. M#2024-04-05 17:14
            let selectedDate = DateUtility.stringToDate(elements[1]) ?? Date.now // The string contains the day e.g. 2024-04-05 17:14 and its transformed to a date component
            
            // Extract the day, hour, and minute components from selectedDate
            let calendar = Calendar.current
            let day = calendar.component(.day, from: selectedDate)
            let hour = calendar.component(.hour, from: selectedDate)
            let minute = calendar.component(.minute, from: selectedDate)
            
            // Save the extracted information on dateComponents, to use it on triggering the notification
            var dateComponents = DateComponents()
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            // Trigger the notification
            notificationRequest(symptomId, dateComponents, content)
        default:
            // Dont do anything when the type of notification wasnt specified
            return
        }
    }
    // Function that makes the notification request
    func notificationRequest(_ symptomId: String, _ dateComponents: DateComponents, _ content: UNMutableNotificationContent) {
        let idNotification = UUID().uuidString

        // Makes the request to create the notification
        let triggerDate = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: idNotification, content: content, trigger: triggerDate)
        UNUserNotificationCenter.current().add(request) // Add the notification
        
        // Saves the notification on user defaults
        addNotification(for: symptomId, notificationID: idNotification)
    }
    
    // Remove all notifications
    func cancelAllNotifications() {
        // First, clean the user defaults that save the notifications
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: notificationsKey)
    
        // Clean the notification manager
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // cancel any upcoming notifications that havent occurred
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // this removes all the notifications that the user is seeing in the home page
    }
    
    // The next functions are for managing the notifications on swift
    // Pass a dictionary and save the notifications
    func saveNotifications(for symptoms: [String: [String]]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(symptoms, forKey: notificationsKey)
    }
    // Retrieve all notifications or return an empty dictionary when there are none
    func retrieveNotifications() -> [String: [String]] {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: notificationsKey) as? [String: [String]] ?? [:]
    }
    // Add a new notification to users defaults
    func addNotification(for symptomID: String, notificationID: String) {
        var notifications = retrieveNotifications()
        if notifications[symptomID] != nil {
            notifications[symptomID]?.append(notificationID)
        } else {
            notifications[symptomID] = [notificationID]
        }
        saveNotifications(for: notifications)
    }
    // Remove all notifications associated with a specific symptom id
    func removeAllNotifications(for symptomID: String) {
        var notifications = retrieveNotifications()
        let allNotifications = notifications[symptomID] ?? []
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allNotifications)
        
        notifications.removeValue(forKey: symptomID)
        saveNotifications(for: notifications)
    }
}

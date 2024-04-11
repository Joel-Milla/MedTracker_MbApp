//
//  ConfigureNotificationsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

// All the possible frequencies of a notification on an enum
enum NotificationFrequency: String, CaseIterable, Identifiable {
    case daily = "Diaria"
    case weekly = "Semanal"
    case monthly = "Mensual"
//    case customize = "Personalizar"
    
    var id: String { self.rawValue }
}

struct NotificationsView: View {
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    // Selected Frequency
    @State private var selectedFrequency: NotificationFrequency = .daily
    // Date frequency variables
    @State var selectedDate: Date = Date()
    // Variable that will hold the repetition of the notification
    @Binding var codeNotification: String
    // Dates when the selected frequency is weekly
    @State var selectedDays: [String: Bool] = [
        "D": false,
        "L": false,
        "M": false,
        "X": false,
        "J": false,
        "V": false,
        "S": false
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Frecuencia")
                    .frame(maxWidth: .infinity, alignment: .leading)
                // Choose what type of notifications you want
                Picker("Notificaciones", selection: $selectedFrequency.animation()) {
                    ForEach(NotificationFrequency.allCases) {frequency in
                        Text(frequency.rawValue).tag(frequency)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color("blueGreen"))
                
                switch(selectedFrequency) {
                case .daily:
                    DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .frame(maxHeight: 400) // Adjust height as needed for your layout
                        .listRowBackground(Color.blueGreen) // Makes the row background transparent
                case .weekly:
                    WeeklyNotificationsView(selectedDays: $selectedDays, selectedDate: $selectedDate)
                case .monthly:
                    DatePicker("Empieza", selection: $selectedDate, in: HelperFunctions.dateRange, displayedComponents: [.date, .hourAndMinute])
                        .frame(maxHeight: 400)
                    // Customize is too complex to implement, search in the future how to do it
//                case .customize:
//                    PersonalizedNotificationsView(selectedDate: $selectedDate)
                }
                // Save the current notifications
                Button(action: {
                    dismiss()
                }) {
                    Text("Guardar")
                        .gradientStyle() // apply gradient style
                }
                .frame(maxWidth: .infinity) // center the text
            }
            .padding()
            // Set the initial values to be used in notifications to also be on sync with the values received
            .onAppear {
                setVariables()
            }
            // On change of the important variables, save that into notifications
            .onChange(of: selectedFrequency) { _ in
                codeNotification = setNotifications()
            }
            .onChange(of: selectedDate) { _ in
                codeNotification = setNotifications()
            }
            .onChange(of: selectedDays) { _ in
                codeNotification = setNotifications()
            }
            .navigationTitle("Notificaciones")
            // Dismiss the view
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            }
        }
    }
    
    func setVariables() {
        let elements = codeNotification.components(separatedBy: "#") // Returns an empty string when empty
        switch(elements[0]) {
        case "D":
            selectedFrequency = .daily
            selectedDate = DateUtility.stringToHour(elements[1]) ?? Date.now // The string contains an hour like 20:18, so it convert to a date variable and saves it
        case "W":
            selectedFrequency = .weekly
            selectedDate = DateUtility.stringToHour(elements[2]) ?? Date.now // The string contains an hour like 20:18, so it convert to a date variable and saves it
            // This loop traverses the days that contain the string which are days, to convert that to true if the day was selected
            for day in elements[1] {
                let keyDay = String(day) // Convert the character into a string to obtain the value in dictionary
                selectedDays[keyDay] = true
            }
        case "M":
            selectedFrequency = .monthly
            selectedDate = DateUtility.stringToDate(elements[1]) ?? Date.now // The string contains an hour like 20:18, so it convert to a date variable and saves it
        // The following case is when code notification is empty
        default:
            selectedFrequency = .daily
            selectedDate = Date.now // The string contains an hour like 20:18, so it convert to a date variable and saves it
        }
    }
    
    // MARK: Formats of the set notification
    // MARK: Daily -> D#20:18 -> Tell that is daily that repeats at 20:18
    // MARK: Weekly -> W#DLM#20:18 -> Tell that repeats the notification weekly, on the days 'Domingo', 'Lunes', and 'Martes' at 20:18
    // MARK: Monthly -> M#2004-11-22 20:18 -> Tell that it will repeat all the 22s of each month at 20:18
    func setNotifications() -> String {
        switch (selectedFrequency) {
        // When the selected frequency is daily, save the hour in which to repeat the notification
        case .daily:
            var notificationString = "D#"
            let hourValues = DateUtility.hourToString(selectedDate) // If the user selected 20:18, then this string will be '20:18'
            notificationString += hourValues
            return notificationString
        // When the selected frequency is weekly, save all the days in which the notification repeats and save the hour to repeat the notification
        case .weekly:
            var notificationString = "W#"
            let hourValues = DateUtility.hourToString(selectedDate) // If the user selected 20:18, then this string will be '20:18'
            // Iterate through the array and save the information
            for (day, isSelected) in selectedDays {
                if isSelected {
                    notificationString += day
                }
            }
            notificationString += "#\(hourValues)"
            return notificationString
        // When the selected frequency is monthly, save that is monthly and save the day to repeat each month with this format->2004-11-22 20:18
        case .monthly:
            var notificationString = "M#"
            let dayValues = DateUtility.dateToString(selectedDate) // Use DateUtility to format and deformat the date
            notificationString += dayValues
            return notificationString
        }
    }
}

#Preview {
    NavigationStack {
        @State var codeNotification: String = ""
        NotificationsView(codeNotification: $codeNotification)
    }
}

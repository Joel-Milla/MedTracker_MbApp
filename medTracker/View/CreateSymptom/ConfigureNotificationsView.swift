//
//  ConfigureNotificationsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

// All the possible frequencies of a notification on an enum
enum NotificationFrequency: String, CaseIterable, Identifiable {
    case daily = "Cada Día"
    case weekly = "Cada Semana"
    case monthly = "Cada Mes"
    case customize = "Personalizar"
    
    var id: String { self.rawValue }
}

struct ConfigureNotificationsView: View {
    @State private var selectedFrequency: NotificationFrequency = .daily
    
    // Day freqencuy variables
    @State private var selectedDate: Date = Date()
    
    // Configure the date picker components
    var datePickerComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    var body: some View {
        VStack {
            Picker("Notificaciones", selection: $selectedFrequency) {
                ForEach(NotificationFrequency.allCases) {frequency in
                    Text(frequency.rawValue).tag(frequency)
                }
            }
            switch(selectedFrequency) {
            case .daily:
                DatePicker("Select Day and Hour", selection: $selectedDate, displayedComponents: datePickerComponents)
                    .datePickerStyle(DefaultDatePickerStyle())
                    .frame(maxHeight: 400) // Adjust height as needed for your layout
                
            case .weekly:
                DatePicker("Select Day and Hour", selection: $selectedDate, displayedComponents: datePickerComponents)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(maxHeight: 400) // Adjust height as needed for your layout
            case .monthly:
                DatePicker("Select Day and Hour", selection: $selectedDate, displayedComponents: datePickerComponents)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 400) // Adjust height as needed for your layout
            case .customize:
                DatePicker("Select Day and Hour", selection: $selectedDate, displayedComponents: datePickerComponents)
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(maxHeight: 400) // Adjust height as needed for your layout
            }
        }
    }
}

#Preview {
    ConfigureNotificationsView()
}

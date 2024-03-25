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
    case customize = "Personalizar"
    
    var id: String { self.rawValue }
}

struct NotificationsView: View {
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    // Selected Frequency
    @State private var selectedFrequency: NotificationFrequency = .daily
    // Date frequency variables
    @State var selectedDate: Date = Date()
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
                    DatePicker("Selecciona el día y la hora", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .frame(maxHeight: 400)
                case .customize:
                    DatePicker("Escoge el día y la hora", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxHeight: 400)
                }
            }
            .padding()
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
}

#Preview {
    
    NotificationsView()
}

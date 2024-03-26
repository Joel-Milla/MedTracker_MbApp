//
//  WeeklyNotificationsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct WeeklyNotificationsView: View {
    @Binding var selectedDays: [String: Bool]
    @Binding var selectedDate: Date
    
    var body: some View {
        WeeklyIntervalView(selectedDays: $selectedDays)
        DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
            .frame(maxHeight: 400) // Adjust height as needed for your layout
    }
}

#Preview {
    NavigationStack {
        @State var selectedDays: [String: Bool] = [
            "D": false,
            "L": false,
            "M": false,
            "X": false,
            "J": false,
            "V": false,
            "S": false
        ]
        @State var selectedDate: Date = Date()
        
        WeeklyNotificationsView(selectedDays: $selectedDays, selectedDate: $selectedDate)
    }
}

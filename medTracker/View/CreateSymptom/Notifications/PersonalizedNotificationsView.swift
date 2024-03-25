//
//  PersonalizedNotificationsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct PersonalizedNotificationsView: View {
    @Binding var selectedDate: Date
    @State var selectedNumber = 1
    @State var selectedInterval: String = ""
    // Possible frequency ranges
    @State var intervals = ["Día ", "Semana ", "Mes "]
    var body: some View {
        HStack {
            // Stepper to select the number of repetition
            Stepper(value: $selectedNumber, in: 1...100) {
                Text("Repetir cada \(selectedNumber) \(selectedNumber == 1 ? "día" : "días")")
                    .fixedSize() // Ensure the text does not change size
            }
            // Select the interval
            Picker(selection: $selectedInterval, label: Text("Interval")) {
                ForEach(intervals, id: \.self) { interval in
                    Text(interval)
                }
            }
            .tint(Color.blueGreen)
            .pickerStyle(MenuPickerStyle())
            .fixedSize() // Avoid the items form dispalcing
            .frame(width: 80) // Fix size to avoid displacing the elements
        }
        // Select when it starts
        DatePicker("Empieza", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(CompactDatePickerStyle())
            .frame(maxHeight: 400)
    }
    
    // Function that returns the string in a formatted way
    func intervalToString(of number: Int, as interval: String) -> String {
        switch(interval) {
        case "Día":
            if (number == 1) {
                return "Repetir cada \(number) día"
            }
            return "Repetir cada \(number) días"
        case "Semana":
            if (number == 1) {
                return "Repetir cada \(number) semana"
            }
            return "Repetir cada \(number) semanas"
        case "Mes":
            if (number == 1) {
                return "Repetir cada \(number) mes"
            }
            return "Repetir cada \(number) meses"
        default:
            if (number == 1) {
                return "Repetir cada \(number) día"
            }
            return "Repetir cada \(number) días"
        }
    }
}

#Preview {
    NavigationStack {
        @State var selectedDate: Date = Date()
        
        PersonalizedNotificationsView(selectedDate: $selectedDate)
    }
}

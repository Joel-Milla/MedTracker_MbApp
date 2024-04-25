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
    @State var selectedInterval: String = "Día"
    // Possible frequency ranges
    @State var intervals = ["Día", "Semana", "Mes"]
    // Values when the frequency is weekly
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
        HStack {
            // Stepper to select the number of repetition
            Stepper(value: $selectedNumber, in: 1...100) {
                HStack {
                    Text("Frecuencia: ")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(selectedNumber)")
                }
            }
            // Select the interval
            Picker(selection: $selectedInterval, label: Text("Interval")) {
                ForEach(intervals, id: \.self) { interval in
                    Text(interval).tag(interval)
                }
            }
            .tint(Color.blueGreen)
            .pickerStyle(MenuPickerStyle())
            .fixedSize() // Avoid the items form dispalcing
            .frame(width: 90) // Fix size to avoid displacing the elements
        }
        // Show the frequency
        Text(intervalToString(of: selectedNumber, as: selectedInterval))
        if (selectedInterval == "Semana") {
            WeeklyIntervalView(selectedDays: $selectedDays) // Select the days of the week
        }
        Spacer()
        // Select when it starts
        DatePicker("Empieza", selection: $selectedDate, in: HelperFunctions.dateRange, displayedComponents: [.date, .hourAndMinute])
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

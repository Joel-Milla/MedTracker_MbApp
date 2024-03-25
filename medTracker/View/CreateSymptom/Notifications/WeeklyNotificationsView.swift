//
//  WeeklyNotificationsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct WeeklyNotificationsView: View {
    let days = ["D", "L", "M", "X", "J", "V", "S"]
    // Variables to know which day was selected
    @Binding var selectedDays: [String: Bool]
    @Binding var selectedDate: Date
    
    var body: some View {
        Text("Se repite el")
            .frame(maxWidth: .infinity, alignment: .leading)
        HStack {
            ForEach(days, id: \.self) { day in
                Button(action: {
                    selectedDays[day]?.toggle()
                }) {
                    Text(day)
                        .foregroundStyle(selectedDays[day]! ? Color.white : Color.blueGreen)
                        .frame(width: 36, height: 36)
                        .background(selectedDays[day]! ? Color(.blueGreen) : .clear)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.mainBlue, lineWidth: 2)
                        )
                }
            }
        }
        .padding()
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

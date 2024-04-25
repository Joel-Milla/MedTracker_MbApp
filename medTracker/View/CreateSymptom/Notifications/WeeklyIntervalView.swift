//
//  WeeklyIntervalView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct WeeklyIntervalView: View {
    let days = ["D", "L", "M", "X", "J", "V", "S"]
    // Variables to know which day was selected
    @Binding var selectedDays: [String: Bool]
    
    var body: some View {
        Text("Se repite el")
            .frame(maxWidth: .infinity, alignment: .leading)
        // Show an hstack of all the days of the week for the user to select them
        HStack {
            ForEach(days, id: \.self) { day in
                Button(action: {
                    selectedDays[day]?.toggle()
                }) {
                    Text(day)
                        .foregroundStyle(selectedDays[day]! ? Color.white : Color.blueGreen)
                        .frame(width: 25, height: 25)
                        .background(selectedDays[day]! ? Color(.blueGreen) : .clear)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.mainBlue, lineWidth: 2)
                        )
                }
            }
        }
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
        
        WeeklyIntervalView(selectedDays: $selectedDays)
    }
}

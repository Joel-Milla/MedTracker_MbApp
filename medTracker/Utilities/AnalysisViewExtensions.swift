//
//  ExtensionsAnalysis.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import Foundation

extension Register {
    // Returns a register that instead of having the complete date, only returns a day
    func adjustDateToDay() -> Register {
        let calendar = Calendar.current
        var adjustedRegister = self
        adjustedRegister.date = calendar.startOfDay(for: self.date)
        return adjustedRegister
    }
}

extension [Register] {
    // Filter an array of registers by tags.
    func filterBy(_ filter: String) -> [Register] {
        // Array containing the filtered registers
        var filteredRegisters: [Register] = []
        
        switch(filter) {
        case "Semana":
            // Date of last seven days
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            
            // Start from the end since the array is sorted by date
            for register in self.reversed() {
                if register.date >= sevenDaysAgo {
                    filteredRegisters.append(register)
                } else {
                    // Once a register's date is older than the start date, break out of the loop
                    break
                }
            }
        case "Mes":
            // Date of last seven days
            let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            
            // Start from the end since the array is sorted by date, to access the recent dates and not traverse the entire array
            for register in self.reversed() {
                if register.date >= monthAgo {
                    filteredRegisters.append(register)
                } else {
                    // Once a register's date is older than the start date, break out of the loop
                    break
                }
            }
        case "Todos":
            return self
        default:
            return self
        }
        
        // Return if filter is Semana/Mes, the filtered registers
        // The data was appended to make it O(1) operation, but if appended then it makes it in descending order, so reverse it so it is in ascending order which should be the default
        return filteredRegisters.reversed()
    }
    
    // Functions used for insightsView, obtain the min value
    func minValue() -> Float? {
        guard !self.isEmpty else { return nil }
        return self.min(by: { $0.amount < $1.amount })?.amount
    }
    
    // Functions used for insightsView, obtain the max value
    func maxValue() -> Float? {
        guard !self.isEmpty else { return nil }
        return self.max(by: { $0.amount < $1.amount })?.amount
    }
    
    // Functions used for insightsView, obtain the min value
    func meanValue() -> Float? {
        guard !self.isEmpty else { return nil }
        let sum = self.reduce(0.0) { $0 + $1.amount }
        return sum / Float(self.count)
    }
    
    // Functions used for bar chart view, obtain the days of all the dates so its easier to preprocess the data
    func adjustDatesToStartOfDay() -> [Register] {
        return self.map { register in
            return register.adjustDateToDay()
        }
    }
}

extension Float {
    // Function to write the cantidad of a register in a nice format
    func asString() -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            // It's an integer, show without decimal places
            return String(format: "%.0f", self)
        } else {
            // It's not an integer, show with up to two decimal places
            return String(format: "%.2f", self).replacingOccurrences(of: ".00", with: "")
        }
    }
}

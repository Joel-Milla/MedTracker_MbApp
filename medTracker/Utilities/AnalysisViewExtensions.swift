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
        adjustedRegister.fecha = calendar.startOfDay(for: self.fecha)
        return adjustedRegister
    }
}

extension [Register] {
    // Filter an array of registers by tags.
    func filterBy(_ filter: String) -> [Register] {
        switch(filter) {
        case "Semana":
            // Date of last seven days
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return self.filter({ register in
                register.fecha > sevenDaysAgo
            })
        case "Mes":
            // Date of last seven days
            let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            return self.filter({ register in
                register.fecha > monthAgo
            })
        case "Todos":
            return self
        default:
            return self
        }
    }
    
    // Functions used for insightsView, obtain the min value
    func minValue() -> Float {
        self.min(by: { $0.cantidad < $1.cantidad })?.cantidad ?? 0.0
    }
    
    // Functions used for insightsView, obtain the max value
    func maxValue() -> Float {
        self.max(by: { $0.cantidad < $1.cantidad })?.cantidad ?? 0.0
    }
    
    // Functions used for insightsView, obtain the min value
    func meanValue() -> Float {
        guard !self.isEmpty else { return 0.0 }
        let sum = self.reduce(0.0) { $0 + $1.cantidad }
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

//
//  ExtensionsAnalysis.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import Foundation

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
    
    // Functions used for insightsView
    func minValue() -> Float {
        self.min(by: { $0.cantidad < $1.cantidad })?.cantidad ?? 0.0
    }
    
    func maxValue() -> Float {
        self.max(by: { $0.cantidad < $1.cantidad })?.cantidad ?? 0.0
    }
    
    func meanValue() -> Float {
        guard !self.isEmpty else { return 0.0 }
        let sum = self.reduce(0.0) { $0 + $1.cantidad }
        return sum / Float(self.count)
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

extension Date {
    // Returns the date as a string on Format MM d - h:m
    func dateToStringMDH() -> String {
        let formatter = DateFormatter()
        // Include abbreviated month name, day, hour, and minute
        formatter.dateFormat = "MMM d - H:mm" // Example: "Feb 23 - 15:14"
        formatter.locale = Locale(identifier: "es_MX") // Spanish month abbreviations
        return formatter.string(from: self)
    }
    
    // Returns the date as a string on format MM d
    func dateToStringMD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Example: "feb 23"
        formatter.locale = Locale(identifier: "es_MX") // Keep for Spanish month abbreviations
        return formatter.string(from: self)
    }
}

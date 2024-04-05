//
//  DateHelper+DateExtensions.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 05/04/24.
//

import Foundation

class DateUtility {
    // Variable that returns a date formatter for hour and day
    static let dateFormatter: DateFormatter = {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 2004-11-22 20:18
        return dayFormatter
    }()

    static let hourFormatter: DateFormatter = {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm" // Use "hh:mm a" for 12-hour format with AM/PM, e.g. 20:18
        return hourFormatter
    }()
    
    
    // Function to convert a date variable into a string using the formatters
    static func dateToString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func hourToString(_ date: Date) -> String {
        return hourFormatter.string(from: date)
    }
    
    // Function to convert strings into the dates using the formatters
    static func stringToDate(_ date: String) -> Date? {
        return dateFormatter.date(from: date)
    }
    
    // Obtain the current date with the hour passed on the string
    static func stringToHour(_ date: String) -> Date? {
        guard let parsedTime = hourFormatter.date(from: date) else { return nil } // Obtain hour and minute
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: parsedTime)
        let minute = calendar.component(.minute, from: parsedTime)
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return calendar.date(from: dateComponents)
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

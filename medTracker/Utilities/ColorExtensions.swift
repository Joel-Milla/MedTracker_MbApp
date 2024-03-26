//
//  ColorExtensions.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import Foundation
import SwiftUI

public extension Color {
    // The next initializer allows to create instance of a color given a hex color
    init(hex: String) {
        // Remove the # values
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        // Obtain the values of rgb from the given values
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
    
        // Initialize the color with the values red, green, and blue
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)
        
        // Get the RGBA components
        guard let components = uiColor.cgColor.components else {
            return ""
        }
        // Obtain the values red, green, and blue from the previous components
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        // Convert the components to HEX
        let hexString = String(
            format: "#%02lX%02lX%02lX",
            lroundf(red * 255),
            lroundf(green * 255),
            lroundf(blue * 255)
        )
        
        return hexString
    }
}

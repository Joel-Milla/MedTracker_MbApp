//
//  FloatToString.swift
//  medTracker
//
//  Created by Alumno on 21/11/23.
//

import Foundation
import SwiftUI

public extension Float {
    var stringFormat: String {
        if self >= 10000 && self <= 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        } else if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.1f", self).replacingOccurrences(of: ".0", with: "")
    }
}

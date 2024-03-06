//
//  GlobalUtilities.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 06/03/24.
//

import Foundation


// Global variable to control if print statements are enabled
var isPrintEnable = false

func customPrint(_ item: Any) {
    if (!isPrintEnable) {
        return
    }
    print(item)
}

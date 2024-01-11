//
//  DoneButton.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

import Foundation
import SwiftUI

struct KeyboardToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // This pushes the Done button to the right
                    Button("OK") {
                        hideKeyboard()
                    }
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func keyboardToolbar() -> some View {
        self.modifier(KeyboardToolbar())
    }
}

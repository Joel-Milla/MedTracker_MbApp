//
//  Alert+Error.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 29/03/24.
//

import SwiftUI

struct Alert_Error: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// This view handles a personalized allert when receivin error messages. The alert recieves a title and a binding error and displays that value into an alert.
private struct ErrorAlertViewModifier: ViewModifier {
    let title: String
    @Binding var error: Error?
    
    func body(content: Content) -> some View {
        content
        // Show the alert when the error has a value and prints the error
            .alert(title, isPresented: $error.hasValue, presenting: error, actions: { _ in }) { error in
                Text(error.localizedDescription)
            }
    }
}

// Use extensions to know if it exists an error and shows it as a view.
extension Optional {
    var hasValue: Bool {
        get { self != nil }
        set { self = newValue ? self : nil }
    }
}

extension View {
    func alert(_ title: String, error: Binding<Error?>) -> some View {
        modifier(ErrorAlertViewModifier(title: title, error: error))
    }
}

#Preview {
    Alert_Error()
}

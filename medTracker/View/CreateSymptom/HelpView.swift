//
//  HelpView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct HelpView: View {
    // Values show on view
    @State var title: String
    // Variable to show the alert
    @State private var showHelpAlert = false
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .textCase(.uppercase)
            Button {
                showHelpAlert.toggle() // show the alert when the question mark is clicked
            } label: {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.gray)
            }
        }
        // Show the alert without styling the text to explain the difference between the options
        .alert("Explicación", isPresented: $showHelpAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Con valores cualitativos, hay un deslizador que puedes mover para reflejar cómo te sientes. Para valores cuantitativos, se escribe un número para indicar cómo te sientes.")
        }
        .textCase(nil)
    }
}

#Preview {
    NavigationStack {
        let title = "menu"
        HelpView(title: title)
    }
}

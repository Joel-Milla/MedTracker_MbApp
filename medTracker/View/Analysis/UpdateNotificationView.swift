//
//  UpdateNotificationView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/04/24.
//

import SwiftUI

struct UpdateNotificationView: View {
    // Notifications properties
    @Binding var codeNotification: String
    @State var allowNotifications: Bool = false
    @State var showNotificationView: Bool = false
    @State var stringNotification: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Notificaciones")
                .font(.title2)
                .bold()
            VStack {
                Toggle(isOn: $allowNotifications.animation()) {
                    Text("Permitir Notificaciones")
                }
                .padding() // Apply padding to content directly
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 5)) // Apply shadow to the background
                // Use showNotifications to present the sheet to modify the notifications and only when it is true
                .onChange(of: allowNotifications) { newValue in
                    if (newValue) {
                        showNotificationView = true
                    } else {
                        // Modify the forms notification when user has no notification
                        codeNotification = ""
                    }
                }
                
                // When notifications are allowed, show the notification selected
                if (allowNotifications) {
                    Text(codeNotification)
                }
            }
            // Show the view to select the notification
            .sheet(isPresented: $showNotificationView, content: {
                NotificationsView(codeNotification: $codeNotification)
                    .tint(Color.blueGreen) // Change the accent color to blue green
                    .presentationDetents([.fraction(0.52), .fraction(0.6)]) // Set the width of the sheet to 30%
            })
        }
    }
}

#Preview {
    NavigationStack {
        @State var codeNotification: String = "D#20:18"
        UpdateNotificationView(codeNotification: $codeNotification)
    }
}

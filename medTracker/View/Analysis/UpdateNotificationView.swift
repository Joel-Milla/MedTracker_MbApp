//
//  UpdateNotificationView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/04/24.
//

import SwiftUI

struct UpdateNotificationView: View {
    @Binding var symptom: Symptom
    // Notifications properties
    @State var allowNotifications: Bool
    @State var showNotificationView: Bool = false
    
    // The init sets the initial state of allowNotifications based on the value of the symptom
    init(symptom: Binding<Symptom>) {
        self._symptom = symptom
        // Set the initial state based on the symptom's notification value.
        self._allowNotifications = State(initialValue: symptom.wrappedValue.notification != "")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notificaciones")
                    .font(.title2)
                    .bold()
                Spacer()
                // Show the option to edit the notifications if a notification exist
                if (allowNotifications) {
                    Button("Editar") {
                        showNotificationView = true
                    }
                }
            }
            // Use aligmnet leading for the text inside the Text to be aligned to the left
            VStack(alignment: .leading) {
                Toggle(isOn: $allowNotifications.animation()) {
                    Text("Permitir Notificaciones")
                }
                // Use showNotifications to present the sheet to modify the notifications and only when it is true
                .onChange(of: allowNotifications) { newValue in
                    if (newValue) {
                        showNotificationView = true
                    } else {
                        // Modify the forms notification when user has no notification
                        symptom.notification = ""
                    }
                }
                
                // Divider beteween the views
                Divider()
                    .background(.background)
                
                
                // When notifications are allowed, show the notification selected
                if (allowNotifications) {
                    Text(symptom.notificationString)
                        .padding(.vertical, 2) // Padding to have the same separation as the area above
                }
            }
            .padding()
            .borderStyle()
            
            // Show the view to select the notification
            .sheet(isPresented: $showNotificationView, content: {
                NotificationsView(codeNotification: $symptom.notification)
                    .tint(Color.blueGreen) // Change the accent color to blue green
                    .presentationDetents([.fraction(0.52), .fraction(0.6)]) // Set the width of the sheet to 30%
            })
        }
    }
}

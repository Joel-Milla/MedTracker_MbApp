//
//  AddSymptomView2_0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 24/03/24.
//

import SwiftUI

struct CreateSymptomView: View {
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    
    @State var description: String = ""
    // Notifications properties
    @State var allowNotifications: Bool = false
    @State var showNotifications: Bool = false

    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    CS_NameView()
                }
                // Description of the new symptom
                Section(header: Text("Descripción")) {
                    Text("Describe el dato:")
                    TextEditor(text: $description)
                }
                // Choose the type of symptom
                Section(header: HelpView(title: "Tipo de dato")) {
                    CS_TypeView()
                }
                
                Section(header: Text("Notificaciones")) {
                    // Use animation to show the new view nicely
                    Toggle(isOn: $allowNotifications.animation()) {
                        Text("Permitir Notificaciones")
                    }
                }
                
                Section {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Guardar")
                            .gradientTextStyle() // apply gradient style
                    }
                    .frame(maxWidth: .infinity) // center the text
                    .listRowBackground(Color.clear) // Makes the row background transparent
                }
            }
            .navigationTitle("Crear Dato")
            // Use showNotifications to present the sheet to modify the notifications and only when it is true
            .onChange(of: allowNotifications) { newValue in
                if (newValue) {
                    showNotifications = true
                }
            }
            // Show the view to select the notification
            .sheet(isPresented: $showNotifications, content: {
                NotificationsView()
                    .presentationDetents([.fraction(0.5)]) // Set the width of the sheet to 30%
            })
            // Dismiss the view
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            }
        }
    }
}


#Preview {
    CreateSymptomView()
}

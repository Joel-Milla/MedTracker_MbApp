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
    
    @StateObject var formViewModel: FormViewModel<Symptom>
    // Notifications properties
    @State var allowNotifications: Bool = false
    @State var showNotificationView: Bool = false
    @State var stringNotification: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Select the name of the symptom and select the icon
                Section(header: MandatoryField(text: "Nombre")) {
                    CS_NameView(name: $formViewModel.nombre, selectedIcon: $formViewModel.icon, colorToSave: $formViewModel.color)
                }
                // Description of the new symptom
                Section(header: MandatoryField(text: "Nombre")) {
                    Text("Describe el dato:")
                    TextEditor(text: $formViewModel.description)
                }
                // Choose the type of symptom
                Section(header: HelpView(title: "Tipo de dato")) {
                    CS_TypeView(cuantitativo: $formViewModel.cuantitativo, selectedUnit: $formViewModel.unidades)
                }
                // Header view to show an edit button when the user has notifications enabled
                Section(header: NotificationHeaderView(allowNotifications: $allowNotifications, showNotificationView: $showNotificationView)) {
                    // Use animation to show the new view nicely
                    Toggle(isOn: $allowNotifications.animation()) {
                        Text("Permitir Notificaciones")
                    }
                    if (allowNotifications) {
                        Text(formViewModel.notificacion)
                    }
                }
                
                Section {
                    Button(action: {
                        // Make the form submit
                        formViewModel.submit()
                    }) {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $formViewModel.state, title: "Guardar")
                    }
                    .gradientStyle() // apply gradient style
                }
            }
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(formViewModel.submit)
            .navigationTitle("Crear Dato")
            // Show alert to tell the user that there is an error
            .alert("Error al guardar datos", error: $formViewModel.error)
            // The next on change checks the state of the form submit and dismiss this view when it is completed succesfullly
            .onChange(of: formViewModel.state) { newValue in
                if (newValue == .successfullyCompleted ) {
                    dismiss()
                }
            }
            // Use showNotifications to present the sheet to modify the notifications and only when it is true
            .onChange(of: allowNotifications) { newValue in
                if (newValue) {
                    showNotificationView = true
                }
            }
            // Show the view to select the notification
            .sheet(isPresented: $showNotificationView, content: {
                NotificationsView(codeNotification: $formViewModel.notificacion)
                    .tint(Color.blueGreen) // Change the accent color to blue green
                    .presentationDetents([.fraction(0.52), .fraction(0.6)]) // Set the width of the sheet to 30%
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
    NavigationStack {
        @State var formViewModel: FormViewModel<Symptom> = FormViewModel(initialValue: Symptom(), action: {_ in })
        CreateSymptomView(formViewModel: formViewModel)
    }
}

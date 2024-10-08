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
    // Handles the form submission to create a new register
    @StateObject var formViewModel: FormViewModel<Symptom>
    // Notifications properties
    @State var allowNotifications: Bool = false
    @State var showNotificationView: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Select the name of the symptom and select the icon
                Section(header: MandatoryField(text: "Nombre")) {
                    CS_NameView(name: $formViewModel.name, selectedIcon: $formViewModel.icon, colorToSave: $formViewModel.color)
                }
                // Description of the new symptom
                Section(header: MandatoryField(text: "Descripción")) {
                    Text("Describe el dato:")
                    TextEditor(text: $formViewModel.description)
                }
                // Choose the type of symptom
                Section(header: HelpView(title: "Tipo de dato")) {
                    CS_TypeView(cuantitativo: $formViewModel.isQuantitative, selectedUnit: $formViewModel.units)
                }
                // Header view to show an edit button when the user has notifications enabled
                Section(header: NotificationHeaderView(allowNotifications: $allowNotifications, showNotificationView: $showNotificationView)) {
                    // Use animation to show the new view nicely
                    Toggle(isOn: $allowNotifications.animation()) {
                        Text("Permitir Notificaciones")
                    }
                    // Use showNotifications to present the sheet to modify the notifications and only when it is true
                    .onChange(of: allowNotifications) { newValue in
                        if (newValue) {
                            showNotificationView = true
                        } else {
                            // Modify the forms notification when user has no notification
                            formViewModel.notification = ""
                        }
                    }
                    
                    // When notifications are allowed, show the notification selected
                    if (allowNotifications) {
                        Text(formViewModel.value.notificationString)
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
            .navigationTitle("Crear Dato")
            // MARK: The following edits are in charge of a good user experience
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(formViewModel.submit)
            // Show alert to tell the user that there is an error
            .alert("Error al guardar datos", error: $formViewModel.error)
            // The next on change checks the state of the form submit and dismiss this view when it is completed succesfullly
            .onChange(of: formViewModel.state) { newValue in
                if (newValue == .successfullyCompleted ) {
                    dismiss()
                }
            }
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
            // MARK: Ending of general user experience
            // Show the view to select the notification
            .sheet(isPresented: $showNotificationView, content: {
                NotificationsView(codeNotification: $formViewModel.notification)
                    .tint(Color.blueGreen) // Change the accent color to blue green
                    .presentationDetents([.fraction(0.52), .fraction(0.6)]) // Set the width of the sheet to 30%
            })
        }
    }
}


#Preview {
    NavigationStack {
        @State var formViewModel: FormViewModel<Symptom> = FormViewModel(initialValue: Symptom(), action: {_ in })
        CreateSymptomView(formViewModel: formViewModel)
    }
}

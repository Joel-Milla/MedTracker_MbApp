//
//  editarLista.swift
//  medTracker
//
//  Created by Alumno on 09/11/23.
//

import SwiftUI

/**********************
 This view edits the symptoms that are being tracked.
 **********************************/
struct EditSymptomView: View {
    @State var muestraAddSymptomView = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var symptoms: SymptomList
    @ObservedObject var registers : RegisterList
    @State private var showConfirmationDialog = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Show a view with a message indicating the user that there are no symptoms being checked.
                if symptoms.symptoms.isEmpty {
                    EmptyListView(
                        title: "No hay datos registrados",
                        message: "Favor de agregar datos para poder empezar a registrar.",
                        nameButton: "Agregar Dato",
                        action: { muestraAddSymptomView = true }
                    )
                }
                // If there are symptoms, then show them on a list.
                else {
                    List {
                        Section(header: Text("Lista de datos de salud"), footer: Text("Deslice para borrar ó seleccione para desactivar")) {
                            ForEach(symptoms.symptoms.indices, id:\.self) { index in
                                let symptom = symptoms.symptoms[index]
                                ShowEditSymptomView(symptom: EditSymptomViewModel(symptom: symptom, deleteSymptomAction: symptoms.makeDeleteAction(for: symptom), updateAction: symptoms.makeUpdateAction(for: symptom), deleteRegisterAction: registers.makeDeleteAction(for: symptom)), symptoms: symptoms, registers: registers)
                            }
                        }
                    }
                    .animation(.default, value: symptoms.symptoms)
                    .font(.title3)
                    .navigationTitle("Editar Datos")
                }
            }
            .toolbar {
                // Shows the back button to homeView
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                        //Text("Volver")
                    })
                }
                // Button to add a new symptom.
            }
            .sheet(isPresented: $muestraAddSymptomView) {
                AddSymptomView(symptoms: symptoms, createAction: symptoms.makeCreateAction())
            }
        }
    }
}

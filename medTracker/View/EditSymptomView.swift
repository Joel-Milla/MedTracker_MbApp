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
                        Section(header: Text("Lista de datos de salud")) {
                            ForEach(symptoms.symptoms.indices, id: \.self) { index in
                                HStack{
                                    Image(systemName: symptoms.symptoms[index].icon)
                                        .foregroundColor(Color(hex: symptoms.symptoms[index].color))
                                    Toggle(symptoms.symptoms[index].nombre, isOn: $symptoms.symptoms[index].activo)
                                        .font(.title2)
                                        .padding(5)
                                }
                            }
                            .swipeActions {
                                Button {
                                    showConfirmationDialog = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .confirmationDialog("¿Estas seguro de querer borrar el dato de salud?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                        Button(role: .destructive, action: {}) {
                            Text("Borrar")
                        }
                    }
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

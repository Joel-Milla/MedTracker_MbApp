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
    @State private var refreshID = UUID() //Serves to force the view to update
    @State var muestraAddSymptomView = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var listaDatos: SymptomList
    
    var body: some View {
        NavigationView {
            VStack {
                // Show a view with a message indicating the user that there are no symptoms being checked.
                if listaDatos.symptoms.isEmpty {
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
                            ForEach(listaDatos.symptoms.indices, id: \.self) { index in
                                HStack{
                                    Image(systemName: listaDatos.symptoms[index].icon)
                                        .foregroundColor(Color(hex: listaDatos.symptoms[index].color))
                                    Toggle(listaDatos.symptoms[index].nombre, isOn: $listaDatos.symptoms[index].activo)
                                        .font(.title2)
                                        .padding(5)
                                }
                            }
                        }
                    }
                    .id(refreshID)  // Force the view to update
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
                AddSymptomView(symptoms: listaDatos, createAction: listaDatos.makeCreateAction())
                    .onChange(of: listaDatos.symptoms) { _ in
                        refreshID = UUID() //Refresh the id to force the view to update.
                    }
            }
        }
    }
}

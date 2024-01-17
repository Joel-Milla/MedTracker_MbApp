//
//  ShowSymptom.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 16/01/24.
//

import SwiftUI

struct ShowEditSymptomView: View {
    let index: Int
    @ObservedObject var symptoms: SymptomList
    @ObservedObject var registers : RegisterList
    @State private var showConfirmationDialog = false

    var body: some View {
        HStack {
            Image(systemName: symptoms.symptoms[index].icon)
                .foregroundColor(Color(hex: symptoms.symptoms[index].color))
            Toggle(symptoms.symptoms[index].nombre, isOn: $symptoms.symptoms[index].activo)
                .font(.title2)
                .padding(5)
        }
        .swipeActions {
            Button {
                showConfirmationDialog = true
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
        .confirmationDialog("¿Seguro de querer borrar el dato de salud?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button(role: .destructive, action: {
                symptoms.deleteSymptom(symptom: symptoms.symptoms[index])
                registers.deleteRegister(indexSymptom: index)
            }) {
                Text("Borrar")
            }
        }
    }
}

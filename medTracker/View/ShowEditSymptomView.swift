//
//  ShowSymptom.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 16/01/24.
//

import SwiftUI

struct ShowEditSymptomView: View {
    @State var symptom: Symptom
    @ObservedObject var symptoms: SymptomList
    @ObservedObject var registers : RegisterList
    @State private var showConfirmationDialog = false

    var body: some View {
        HStack {
            Image(systemName: symptom.icon)
                .foregroundColor(Color(hex: symptom.color))
            Toggle(symptom.nombre, isOn: $symptom.activo)
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
                symptoms.deleteSymptom(symptom: symptom)
                registers.deleteRegister(indexSymptom: symptom.id.uuidString)
            }) {
                Text("Borrar")
            }
        }
    }
}

//
//  ShowSymptom.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 16/01/24.
//

import SwiftUI

struct ShowEditSymptomView: View {
//    @ObservedObject var symptom: EditSymptomViewModel
//    @ObservedObject var symptoms: SymptomList
//    @ObservedObject var registers : RegisterList
//    @State private var showConfirmationDialog = false
    @State var variable1: Bool = false
    @State var showConfirmationDialog: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "heart")
                .foregroundColor(.red)
            Toggle("Name", isOn: $variable1)
                .font(.title2)
                .padding(5)
        }
//        .onChange(of: symptoms.symptom.activo) { newValue in
//            symptom.updateValueActivo()
//        }
        .swipeActions {
            Button {
                showConfirmationDialog = true
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
        .confirmationDialog("¿Seguro de querer borrar el dato de salud y todos sus registros?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button(role: .destructive, action: {
            }) {
                Text("Borrar")
            }
        }
    }
}

//
//  ShowSymptom.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 16/01/24.
//

import SwiftUI

//struct ShowEditSymptomView: View {
//    @ObservedObject var symptom: EditSymptomViewModel
//    @ObservedObject var symptoms: SymptomList
//    @ObservedObject var registers : RegisterList
//    @State private var showConfirmationDialog = false
//
//    var body: some View {
//        HStack {
//            Image(systemName: symptom.symptom.icon)
//                .foregroundColor(Color(hex: symptom.symptom.color))
//            Toggle(symptom.symptom.nombre, isOn: $symptom.symptom.activo)
//                .font(.title2)
//                .padding(5)
//        }
//        .onChange(of: symptom.symptom.activo) { newValue in
//            symptom.updateValueActivo()
//        }
//        .swipeActions {
//            Button {
//                showConfirmationDialog = true
//            } label: {
//                Image(systemName: "trash")
//            }
//            .tint(.red)
//        }
//        .confirmationDialog("¿Seguro de querer borrar el dato de salud y todos sus registros?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
//            Button(role: .destructive, action: {
//                symptoms.deleteSymptom(symptom: symptom.symptom)
//                registers.deleteRegistersSymptom(indexSymptom: symptom.symptom.id.uuidString)
//            }) {
//                Text("Borrar")
//            }
//        }
//    }
//}

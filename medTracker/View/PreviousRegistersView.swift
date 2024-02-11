//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct PreviousRegistersView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var registers: RegisterList
    let symptom: Symptom

    var body: some View {
        NavigationStack {
            List {
                ForEach(registers.registers.filter({ $0.idSymptom == symptom.id.uuidString }).sorted(by: {$0.fecha > $1.fecha})) { register in
                    rowRegister(register: register, symptom: symptom)
                }
                .onDelete { indexSet in
                    registers.deleteRegisterSet(atOffset: indexSet, ofSymptom: symptom)
                }
            }
            .navigationTitle(symptom.nombre)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .padding()
                }
            }
        }
    }
}

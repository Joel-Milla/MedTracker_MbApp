//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct PreviousRegistersView: View {
    @Environment(\.dismiss) var dismiss
    @State var registers: [Register]
    let symptom: Symptom

    var body: some View {
        NavigationStack {
            List {
                ForEach(registers) { register in
                    rowRegister(register: register, symptom: symptom)
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
            }
        }
    }
}

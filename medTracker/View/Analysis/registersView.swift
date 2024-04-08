//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct registersView: View {
    //    @ObservedObject var registers: RegisterList
    //    let symptom: Symptom
    let symptom = Symptom(nombre: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", cuantitativo: true, unidades: "kg", activo: true, color: "#007AFF", notificacion: "")
    
    @State var symptomRegisters: [Register]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(symptomRegisters.sorted(by: {$0.date > $1.date})) { register in
                    rowRegister(register: register, symptom: symptom)
                }
                .onDelete { indexSet in
                    symptomRegisters.remove(atOffsets: indexSet)
                    //                    registers.deleteRegisterSet(atOffset: indexSet, ofSymptom: symptom)
                }
            }
            .navigationTitle(symptom.nombre)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .padding()
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        @State var symptomRegisters = RegisterList.getDefaultRegisters()
        registersView(symptomRegisters: symptomRegisters)
    }
}

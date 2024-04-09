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
    let symptom = Symptom(name: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", isQuantitative: true, units: "kg", isActive: true, color: "#007AFF", notification: "")
    
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
            .navigationTitle(symptom.name)
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

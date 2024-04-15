//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct registersView: View {
    let symptom: Symptom
    
    @State var registers: [Register]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(registers.reversed()) { register in
                    // Show the custom row register view for each register
                    HStack {
                        // Show the name and date of the register
                        VStack(alignment: .leading, spacing: 4) {
                            Text(symptom.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: symptom.color))

                            Text(register.date.dateToStringMDH())
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        }

                        Spacer()
                        // Show the amount or an image depending on the type of symptom
                        if symptom.isQuantitative {
                            Text("Cantidad: \(register.amount, specifier: "%.2f")")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        } else {
                            let Image = HelperFunctions.getImage(of: register.amount)
                            Image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                // When using the edit button, delete the registers selected
                .onDelete { indexSet in
                    registers.remove(atOffsets: indexSet)
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
        let symptom = Symptom(name: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", isQuantitative: true, units: "kg", isFavorite: true, color: "#007AFF", notification: "")
        @State var registers = RegisterList.getDefaultRegisters()
        registersView(symptom: symptom, registers: registers)
    }
}

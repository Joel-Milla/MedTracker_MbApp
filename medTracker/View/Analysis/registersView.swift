//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct registersView: View {
    @ObservedObject var editRegistersViewModel: EditRegisterViewModel // ViewModel that contains all the necessary actions here
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(editRegistersViewModel.registers) { register in
                    // Show the custom row register view for each register
                    HStack {
                        // Show the name and date of the register
                        VStack(alignment: .leading, spacing: 4) {
                            Text(editRegistersViewModel.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: editRegistersViewModel.symptom.color))

                            Text(register.date.dateToStringMDH())
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        }

                        Spacer()
                        // Show the amount or an image depending on the type of symptom
                        if editRegistersViewModel.isQuantitative {
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
                    .cornerRadius(8)
                }
                // When using the edit button, delete the registers selected
                .onDelete { indexSet in
                    editRegistersViewModel.removeRegisters(at: indexSet)
                }
            }
            .navigationTitle(editRegistersViewModel.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .padding()
                }
            }
        }
    }
}

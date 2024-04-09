//
//  rowRegister.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 19/01/24.
//

import SwiftUI

struct rowRegister: View {
    var register: Register
    let symptom: Symptom

    var body: some View {
        HStack {
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

            if symptom.isQuantitative {
                Text("Cantidad: \(register.amount, specifier: "%.2f")")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            } else {
                let imageName = HelperFunctions.getImage(of: register.amount)
                Image(imageName)
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
}


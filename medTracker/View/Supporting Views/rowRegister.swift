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
                Text(symptom.nombre)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("blueGreen"))
                
                Text(symptom.description)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                
                Text(register.fecha, formatter: itemFormatter)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}


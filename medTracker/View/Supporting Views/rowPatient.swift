//
//  vistaDetalle.swift
//  medTracker
//
//  Created by Alumno on 25/11/23.
//

//
//  vistaDetalle.swift
//  listaNavigationView
//
//  Created by Alumno on 03/10/23.
//

import SwiftUI

struct rowPatient: View {
    var patient: Patient
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(Color("mainBlue")) // Use the "mainBlue" color for the icon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.title3)
                    .fontWeight(.semibold) // Make the name stand out
                    .foregroundColor(Color("blueGreen")) // Use the "blueGreen" color for the name
                
                Text(patient.email)
                    .font(.footnote)
                    .foregroundColor(Color.gray) // A more subtle color for the email
            }
            
            Spacer() // Pushes everything to the left
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.secondary.opacity(0.1)) // Light background for each row
        .cornerRadius(8) // Rounded corners
    }
}

struct rowPatient_Previews: PreviewProvider {
    static var previews: some View {
        rowPatient(patient: Patient(email: "Joel", name: "yo"))
    }
}


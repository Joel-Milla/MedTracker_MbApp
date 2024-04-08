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
                    .foregroundColor(Color(hex: symptom.color))

                Text(register.date, formatter: itemFormatter)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }

            Spacer()

            if symptom.cuantitativo {
                Text("Cantidad: \(register.amount, specifier: "%.2f")")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            } else {
                let (imageName, imageColor) = getImage(of: register.amount)
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .foregroundColor(imageColor)
            }
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

    func getImage(of value: Float) -> (String, Color) {
        var color: Color
        var imageName: String

        switch value {
        case 0..<20:
            color = Color("green_MT")
            imageName = "happier_face" // Replace with actual system image name
        case 20..<40:
            color = Color("yellowgreen_MT")
            imageName = "va_test" // Replace with actual system image name
        case 40..<60:
            color = Color("yellow_MT")
            imageName = "normal_face" // Replace with actual system image name
        case 60..<80:
            color = Color("orange_MT")
            imageName = "sad_face" // Replace with actual system image name
        case 80...:
            color = Color("red_MT")
            imageName = "sadder_face" // Replace with actual system image name
        default:
            color = Color("mainBlue")
            imageName = "" // Default image name if needed
        }

        return (imageName, color)
    }
}


//
//  InsightsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import SwiftUI

struct InsightsView: View {
    let isCuantitative: Bool
    let symptomRegisters: [Register]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .foregroundColor(Color("blueGreen"))
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
            
            HStack(spacing: 30) {
                VStack {
                    Text("Valor mínimo")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Value(isCuantitative: isCuantitative, value: symptomRegisters.minValue())
                }
                VStack {
                    Text("Valor promedio")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Value(isCuantitative: isCuantitative, value: symptomRegisters.meanValue())
                }
                VStack {
                    Text("Valor máximo")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Value(isCuantitative: isCuantitative, value: symptomRegisters.maxValue())
                }
            }
            .padding() // Adjust the padding as needed
        }
        .frame(height: 80)
    }
}

struct Value: View {
    let isCuantitative: Bool
    let value: Float
    
    var body: some View {
        if (isCuantitative) {
            Text(value.asString())
                .font(.title2.bold())
        } else {
            let imageName = HelperFunctions.getImage(of: value)
            HStack {
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        let symptomRegisters: [Register] = [
            Register(idSymptom: "SYM-571", fecha: Date(), cantidad: 8.51, notas: "Note 66"),
            Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-32400), cantidad: 8.92, notas: "Note 40"),
            Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-86400 * 1), cantidad: 8.92, notas: "Note 40"),
            Register(idSymptom: "SYM-358", fecha: Date().addingTimeInterval(-86400 * 2), cantidad: 1.36, notas: "Note 25"),
            Register(idSymptom: "SYM-797", fecha: Date().addingTimeInterval(-86400 * 3), cantidad: 7.07, notas: "Note 68"),
            Register(idSymptom: "SYM-936", fecha: Date().addingTimeInterval(-86400 * 4), cantidad: 9.86, notas: "Note 33"),
            Register(idSymptom: "SYM-781", fecha: Date().addingTimeInterval(-86400 * 5), cantidad: 3.29, notas: "Note 77"),
            Register(idSymptom: "SYM-272", fecha: Date().addingTimeInterval(-86400 * 6), cantidad: 9.24, notas: "Note 10"),
            Register(idSymptom: "SYM-158", fecha: Date().addingTimeInterval(-86400 * 7), cantidad: 5.29, notas: "Note 90"),
            Register(idSymptom: "SYM-739", fecha: Date().addingTimeInterval(-86400 * 8), cantidad: 2.67, notas: "Note 46"),
            Register(idSymptom: "SYM-342", fecha: Date().addingTimeInterval(-86400 * 9), cantidad: 5.2, notas: "Note 21"),
            Register(idSymptom: "SYM-343", fecha: Date().addingTimeInterval(-86400 * 10), cantidad: 5.2, notas: "Note 22"),
            Register(idSymptom: "SYM-344", fecha: Date().addingTimeInterval(-86400 * 11), cantidad: 5.2, notas: "Note 23"),
            Register(idSymptom: "SYM-345", fecha: Date().addingTimeInterval(-86400 * 12), cantidad: 22, notas: "Note 24"),
            Register(idSymptom: "SYM-346", fecha: Date().addingTimeInterval(-86400 * 13), cantidad: 5.2, notas: "Note 25"),
            Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 14), cantidad: 9, notas: "Note 29"),
            Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 56), cantidad: 3.4, notas: "Note 30")
        ]
        InsightsView(isCuantitative: true, symptomRegisters: symptomRegisters)
    }
}

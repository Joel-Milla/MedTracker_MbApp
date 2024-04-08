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
        let symptomRegisters: [Register] = RegisterList.getDefaultRegisters()
        
        InsightsView(isCuantitative: true, symptomRegisters: symptomRegisters)
    }
}

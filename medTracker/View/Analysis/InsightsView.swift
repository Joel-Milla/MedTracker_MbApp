//
//  InsightsView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import SwiftUI

struct InsightsView: View {
    let isQuantitative: Bool
    let registers: [Register]
    
    var body: some View {
        // Make three columns to organize the information
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
                    Value(isCuantitative: isQuantitative, value: registers.minValue())
                }
                VStack {
                    Text("Valor promedio")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Value(isCuantitative: isQuantitative, value: registers.meanValue())
                }
                VStack {
                    Text("Valor máximo")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Value(isCuantitative: isQuantitative, value: registers.maxValue())
                }
            }
            .padding() // Adjust the padding as needed
        }
        .frame(height: 80)
    }
}

// View that shows the image or the values depending if the symptom is quantitative or not
struct Value: View {
    let isCuantitative: Bool
    let value: Float?
    
    var body: some View {
        // Show different views depending if there is data or not
        if (value != nil) {
            if (isCuantitative) {
                Text(value?.asString() ?? "")
                    .font(.title2.bold())
            } else {
                let imageName = HelperFunctions.getImage(of: value ?? 0.0)
                HStack {
                    Spacer()
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                    Spacer()
                }
            }
        } else {
            Text("--")
        }
    }
}

#Preview {
    NavigationStack {
        let registers: [Register] = []
        
        InsightsView(isQuantitative: true, registers: registers)
    }
}

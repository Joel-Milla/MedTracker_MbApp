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
        VStack(alignment: .leading) {
            // Show the insight values
            Text("Análisis")
                .font(.title2)
                .bold()
            
            HStack(spacing: 30) {
                Value(title: "Valor mínimo", isCuantitative: isQuantitative, value: registers.minValue())
                Value(title: "Valor promedio", isCuantitative: isQuantitative, value: registers.meanValue())
                Value(title: "Valor máximo", isCuantitative: isQuantitative, value: registers.maxValue())
            }
            .frame(maxWidth: .infinity) // Take the whole space horiztonally
            .padding(.vertical, 5) // Apply padding to content directly
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)) // Apply shadow to the background
        }
    }
}

// View that shows the image or the values depending if the symptom is quantitative or not
struct Value: View {
    let title: String
    let isCuantitative: Bool
    let value: Float?
    
    var body: some View {
        // Show different views depending if there is data or not
        VStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
            
            if let value = value {
                if (isCuantitative) {
                    Text(value.asString())
                        .font(.title2.bold())
                } else {
                    let Image = HelperFunctions.getImage(of: value)
                    HStack {
                        Spacer()
                        Image
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
}

#Preview {
    NavigationStack {
        let registers: [Register] = []
        
        InsightsView(isQuantitative: true, registers: registers)
    }
}

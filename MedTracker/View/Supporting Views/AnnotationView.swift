//
//  AnnotationView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 10/04/24.
//

import SwiftUI

//MARK: View to show an annotation depending if the symptom is quant or qual. This annotation is shown on the charts
struct AnnotationView: View {
    let symptom: Symptom
    let register: Register
    
    let minDate: Date
    let maxDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Show the date of the current value and the value
            Group {
                if (symptom.isQuantitative) {
                    Text(register.date.dateToStringMDH())
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(register.amount.asString())
                        .font(.title3.bold())
                } else {
                    Text(register.date.dateToStringMDH())
                        .font(.caption)
                        .foregroundStyle(.gray)
                    // Obtain the image of the current value selected and show it
                    let Image = HelperFunctions.getImage(of: register.amount)
                    HStack {
                        Spacer()
                        Image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.white.shadow(.drop(radius: 2)))
        }
        // Move the annotation when it is on the corners so the annotation shows clearly and not on borders
        .offset(x: register.date.dateToStringMDH() == minDate.dateToStringMDH() ? 35 : register.date.dateToStringMDH() == maxDate.dateToStringMDH() ? -20 : 0)
    }
}
#Preview {
    NavigationStack {
        let symptom = Symptom()
        let register = Register(idSymptom: "1")
        let minDate = Date.now
        let maxDate = Date.now
        AnnotationView(symptom: symptom, register: register, minDate: minDate, maxDate: maxDate)
    }
}

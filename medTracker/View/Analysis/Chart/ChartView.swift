//
//  CuantitativeGraphView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//


import SwiftUI

struct ChartView: View {
    let isCuantitative: Bool
    // Mock data
    let symptomRegisters: [Register]
    // MARK: View Properties
    @State var currentTab: String = "Semana"
    @State var isLineGraph: Bool = true
    
    var body: some View {
        // MARK: Chart API
        VStack(alignment: .leading, spacing: 12) {
            // Picker to switch the time-zone of data shown
            HStack {
                Text("Valores")
                    .fontWeight(.semibold)
                Picker("", selection: $currentTab) {
                    Text("Semana")
                        .tag("Semana")
                    Text("Mes")
                        .tag("Mes")
                    Text("Todos")
                        .tag("Todos")
                }
                .pickerStyle(.segmented)
                .padding(.leading, 50)
            }
            
            // Switch between line and bar graph. Pass the currentTab selected to switch time-zones.
            if (isLineGraph) {
                if (isCuantitative) {
                    LineChartView_Cuant(symptomRegisters: symptomRegisters, currentTab: $currentTab)
                } else {
                    LineChartView_Cual(symptomRegisters: symptomRegisters, currentTab: $currentTab)
                }
            } else {
                if (isCuantitative) {
                    BarChartView_Cuant(symptomRegisters: symptomRegisters, currentTab: $currentTab)
                } else {
                    BarChartView_Cual(symptomRegisters: symptomRegisters, currentTab: $currentTab)
                }
            }
            
            // Picker to shown if chart shown is line or bar chart
            Picker("Tipo de gráfica:", selection: $isLineGraph) {
                Text("Línea").tag(true)
                Text("Barra").tag(false)
            }
            .pickerStyle(.segmented)
            
        }
        .padding() // Following padding is for the label graph to look better
        // Background to add border to the graph
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.shadow(.drop(radius: 2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color("blueGreen"), lineWidth: 2)
                )
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
        
        ChartView(isCuantitative: true, symptomRegisters: symptomRegisters)
    }
}


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
        
        let symptomRegisters: [Register] = RegisterList.getDefaultRegisters()
        
        ChartView(isCuantitative: true, symptomRegisters: symptomRegisters)
    }
}


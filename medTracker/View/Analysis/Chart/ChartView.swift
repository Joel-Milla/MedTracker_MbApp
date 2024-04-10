//
//  CuantitativeGraphView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//


import SwiftUI

struct ChartView: View {
    // Variables to show information
    @State var symptom: Symptom
    @ObservedObject var registers: RegisterList
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
                if (symptom.isQuantitative) {
                    LineChartView_Cuant(symptom: symptom, registers: registers, currentTab: $currentTab)
                } else {
                    LineChartView_Cual(symptom: symptom, registers: registers, currentTab: $currentTab)
                }
            } else {
                if (symptom.isQuantitative) {
                    BarChart2(symptom: symptom, registers: registers, currentTab: $currentTab)
                } else {
                    BarChartView_Cual(symptom: symptom, registers: registers, currentTab: $currentTab)
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
        @State var repository = Repository(user: User(id: "3zPDb70ofQQHximl1NXwPMgIhMR2", rol: "Paciente", email: "joel@mail.com", phone: "", name: "Joel", clinicalHistory: "", sex: "", birthdate: Date.now, height: "", doctors: ["doc@mail.com"]))
        @State var registers: RegisterList = RegisterList(repository: repository)
        
        @State var symptom = Symptom(name: "", icon: "heart", description: "", isQuantitative: true, units: "kg", isActive: true, color: "#000000", notification: "")
                
        ChartView(symptom: symptom, registers: registers)
    }
}


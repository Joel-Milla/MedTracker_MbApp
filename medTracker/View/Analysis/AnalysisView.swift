//
//  AnalysisView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 20/03/24.
//

import SwiftUI

struct AnalysisView: View {
    // Variables that are shown on the view
    let symptom: Symptom
    @ObservedObject var registers: RegisterList
    // To show RegisterSymptomView
    @State var showRegisterSymptomView : Bool = false
    
    var body: some View {
        VStack {
                // Chart that shows the data
                ChartView(symptom: symptom, registers: registers)
                    .padding(.bottom, 35)
                // View that shows summarize data about the points
                InsightsView(isQuantitative: symptom.isQuantitative, registers: registers.registers[symptom.id.uuidString] ?? [])
                    .padding(.bottom, 35)
                // Button to show the past registers
                NavigationLink {
                    registersView(symptom: symptom, registers: registers.registers[symptom.id.uuidString] ?? [])
                } label: {
                    Text("Registros Pasados")
                        .gradientStyle() // Use the default gradient to show the correct style of the button
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(symptom.name)
            .toolbar {
                // Button to traverse to EditSymptomView.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showRegisterSymptomView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showRegisterSymptomView, content: {
                // Create the viewModel that handles the creation of a register and pass the symptom
                RegisterSymptomView(formViewModel: registers.createRegisterViewModel(idSymptom: symptom.id.uuidString), symptom: symptom)
            })
    }
}

#Preview {
    NavigationStack {
        @State var symptomTest = Symptom(name: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", isQuantitative: true, units: "kg", isActive: true, color: "#007AFF", notification: "")
        
        @State var repository = Repository(user: User(id: "3zPDb70ofQQHximl1NXwPMgIhMR2", rol: "Paciente", email: "joel@mail.com", phone: "", name: "Joel", clinicalHistory: "", sex: "", birthdate: Date.now, height: "", doctors: ["doc@mail.com"]))
        @State var registers: RegisterList = RegisterList(repository: repository)
        
        AnalysisView(symptom: symptomTest, registers: registers)
    }
}


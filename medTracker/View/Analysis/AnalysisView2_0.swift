//
//  AnalysisView2.0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 20/03/24.
//

import SwiftUI

struct AnalysisView2_0: View {
    // Variables that are shown on the view
    @State var symptom: Symptom
    // To show RegisterSymptomView
    @State var showRegisterSymptomView : Bool = false
    // To create the viewModel that creates a new register
    @ObservedObject var registers: RegisterList
    
    var body: some View {
            VStack {
                // Chart that shows the data
                ChartView(isCuantitative: symptom.cuantitativo, symptomRegisters: registers.filterBy(symptom))
                    .padding(.bottom, 35)
                // View that shows summarize data about the points
                InsightsView(isCuantitative: symptom.cuantitativo, symptomRegisters: registers.filterBy(symptom))
                    .padding(.bottom, 35)
                // Button to show the past registers
                NavigationLink {
                    registersView(symptomRegisters: registers.filterBy(symptom))
                } label: {
                    Text("Registros Pasados")
                        .gradientStyle() // Use the default gradient to show the correct style of the button
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(symptom.nombre)
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
        @State var symptomTest = Symptom(nombre: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", cuantitativo: true, unidades: "kg", activo: true, color: "#007AFF", notificacion: "")
        
        @State var repository = Repository(user: User(id: "3zPDb70ofQQHximl1NXwPMgIhMR2", rol: "Paciente", email: "joel@mail.com", phone: "", name: "Joel", clinicalHistory: "", sex: "", birthdate: Date.now, height: "", doctors: ["doc@mail.com"]))
        
        @State var registers: RegisterList = RegisterList(repository: repository)
        AnalysisView2_0(symptom: symptomTest, registers: registers)
    }
}


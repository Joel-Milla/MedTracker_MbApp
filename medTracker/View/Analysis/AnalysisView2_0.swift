//
//  AnalysisView2.0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 20/03/24.
//

import SwiftUI

struct AnalysisView2_0: View {
    // Receive mock data
    @State var symptomTest: Symptom
    @State var testRegisters: [Register]
    @State var showRegisterSymptomView : Bool = false // To show RegisterSymptomView
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var sliderValue : Double = 0.0
    
    var body: some View {
            VStack {
                // Chart that shows the data
                ChartView(isCuantitative: symptomTest.cuantitativo, testRegisters: testRegisters)
                    .padding(.bottom, 35)
                // View that shows summarize data about the points
                InsightsView(isCuantitative: symptomTest.cuantitativo, testRegisters: testRegisters)
                    .padding(.bottom, 35)
                // Button to show the past registers
                NavigationLink {
                    registersView()
                } label: {
                    Text("Registros Pasados")
                        .gradientStyle() // Use the default gradient to show the correct style of the button
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(symptomTest.nombre)
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
                RegisterSymptomView(symptom: $symptomTest, registers: authViewModel.makeRegisterList()!, symptoms: authViewModel.makeSymptomList()!, sliderValue: $sliderValue, createAction: {register in})
            })
    }
}

#Preview {
    NavigationStack {
        @State var symptomTest = Symptom(nombre: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", cuantitativo: true, unidades: "kg", activo: true, color: "#007AFF", notificacion: "")
        
        @State var testRegisters: [Register] = [
            Register(idSymptom: "SYM-571", fecha: Date(), cantidad: 8.51, notas: "Note 66"),
            Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-32400), cantidad: 89.2, notas: "Note 40"),
            Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-86400 * 1), cantidad: 89.2, notas: "Note 40"),
            Register(idSymptom: "SYM-358", fecha: Date().addingTimeInterval(-86400 * 2), cantidad: 96, notas: "Note 25"),
            Register(idSymptom: "SYM-797", fecha: Date().addingTimeInterval(-86400 * 3), cantidad: 70.7, notas: "Note 68"),
            Register(idSymptom: "SYM-936", fecha: Date().addingTimeInterval(-86400 * 4), cantidad: 98.6, notas: "Note 33"),
            Register(idSymptom: "SYM-781", fecha: Date().addingTimeInterval(-86400 * 5), cantidad: 32.9, notas: "Note 77"),
            Register(idSymptom: "SYM-272", fecha: Date().addingTimeInterval(-86400 * 6), cantidad: 92.4, notas: "Note 10"),
            Register(idSymptom: "SYM-158", fecha: Date().addingTimeInterval(-86400 * 7), cantidad: 52.9, notas: "Note 90"),
            Register(idSymptom: "SYM-739", fecha: Date().addingTimeInterval(-86400 * 8), cantidad: 26.7, notas: "Note 46"),
            Register(idSymptom: "SYM-342", fecha: Date().addingTimeInterval(-86400 * 9), cantidad: 52, notas: "Note 21"),
            Register(idSymptom: "SYM-343", fecha: Date().addingTimeInterval(-86400 * 10), cantidad: 52, notas: "Note 22"),
            Register(idSymptom: "SYM-344", fecha: Date().addingTimeInterval(-86400 * 11), cantidad: 25, notas: "Note 23"),
            Register(idSymptom: "SYM-345", fecha: Date().addingTimeInterval(-86400 * 12), cantidad: 22, notas: "Note 24"),
            Register(idSymptom: "SYM-346", fecha: Date().addingTimeInterval(-86400 * 13), cantidad: 62, notas: "Note 25"),
            Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 14), cantidad: 90, notas: "Note 29"),
            Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 56), cantidad: 34, notas: "Note 30")
        ]
        AnalysisView2_0(symptomTest: symptomTest, testRegisters: testRegisters)
    }
}


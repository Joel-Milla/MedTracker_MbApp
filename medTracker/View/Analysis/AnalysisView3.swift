//
//  AnalysisView3.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/04/24.
//

import SwiftUI

struct AnalysisView3: View {
    // Variables that are shown on the view
    @State var symptom: Symptom
    @ObservedObject var registers: RegisterList
    // To show RegisterSymptomView
    @State var showRegisterSymptomView : Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Chart that shows the data
                ChartView(symptom: symptom, registers: registers)
                    .padding(.bottom, 5)
                // Button to show the past registers
                NavigationLink {
                    registersView(symptom: symptom, registers: registers.registers[symptom.id.uuidString] ?? [])
                } label: {
                    Text("Registros Pasados")
                        .gradientStyle() // Use the default gradient to show the correct style of the button
                        .padding(.bottom, 12) // Bottom padding
                }
                // View that shows summarize data about the points
                InsightsView(isQuantitative: symptom.isQuantitative, registers: registers.registers[symptom.id.uuidString] ?? [])
                    .padding(.bottom, 12)
                // Show the view to update the notifications
                UpdateNotificationView(codeNotification: $symptom.notification)
                    .padding(.bottom, 35)
            }
            .frame(maxHeight: .infinity, alignment: .top) // Align to vstack to the top of the view
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(symptom.name)
            .padding(.horizontal) // separate the content with the horiztonal borders
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
}


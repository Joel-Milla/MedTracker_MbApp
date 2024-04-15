//
//  AnalysisView3.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 12/04/24.
//

import SwiftUI

struct AnalysisView: View {
    // Variables that are shown on the view
    @ObservedObject var analysisViewModel: FormViewModel<Symptom>
    @ObservedObject var registers: RegisterList
    // To show RegisterSymptomView
    @State var showRegisterSymptomView : Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Chart that shows the data
                ChartView(symptom: analysisViewModel.value, registers: registers)
                    .padding(.bottom, 5)
                // Button to show the past registers
                NavigationLink {
                    registersView(symptom: analysisViewModel.value, registers: registers.registers[analysisViewModel.id.uuidString] ?? [])
                } label: {
                    Text("Registros Pasados")
                        .gradientStyle() // Use the default gradient to show the correct style of the button
                        .padding(.bottom, 12) // Bottom padding
                }
                // View that shows summarize data about the points
                InsightsView(isQuantitative: analysisViewModel.isQuantitative, registers: registers.registers[analysisViewModel.id.uuidString] ?? [])
                    .padding(.bottom, 12)
                // Show the view to update the notifications
                UpdateNotificationView(symptom: $analysisViewModel.value)
                    .padding(.bottom, 35)
            }
            .onChange(of: analysisViewModel.notification) { _ in
                // When notifications are allowed and the user change them, then update the symptom
                analysisViewModel.submit()
            }
            .frame(maxHeight: .infinity, alignment: .top) // Align to vstack to the top of the view
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(analysisViewModel.name)
            .padding(.horizontal) // separate the content with the horiztonal borders
            .toolbar {
                // Button to add to favorites the symptom
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Change if analysisViewModel is a favorite or not
                        analysisViewModel.isActive.toggle()
                        analysisViewModel.submit()
                    } label: {
                        Image(systemName: analysisViewModel.isActive ? "star.fill" : "star")
                            .foregroundStyle(.orange)
                    }
                }
                
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
                RegisterSymptomView(formViewModel: registers.createRegisterViewModel(idSymptom: analysisViewModel.id.uuidString), symptom: analysisViewModel.value)
            })
        }
    }
}


//
//  pagInicio.swift
//  medTracker
//
//  Created by Alumno on 09/11/23.
//

import SwiftUI

/**********************
 This view shows all the symptoms being tracked and has the option to add a new symptom or add a data related to a symptom.
 **********************************/
struct HomeView: View {
    @ObservedObject var symptoms : SymptomList
    @ObservedObject var registers : RegisterList
    @State private var showCreateSymptomView = false
    
    var body: some View {
        ZStack {
            VStack {
                // Show the view based on symptomList state (loading, emptyArray, arrayWithValues).
                switch symptoms.state {
                case .isLoading:
                    ProgressView() //Loading animation
                case .isEmpty:
                    //Calls a view to show that the symptom list is empty
                    //The action serves as a button to send the user to a page to create a symptom.
                    EmptyListView(
                        title: "No hay datos registrados",
                        message: "Favor de agregar datos para poder empezar a registrar.",
                        nameButton: "Agregar Dato",
                        action: { showCreateSymptomView = true }
                    )
                case .complete:
                    List {
                        if !symptoms.sortedFavoriteSymptoms.isEmpty {
                                Section("Favoritos") {
                                    ForEach(symptoms.sortedFavoriteSymptoms) { symptom in
                                        NavigationLink(destination: AnalysisView(analysisViewModel: symptoms.createAnalysisViewModel(for: symptom), registers: registers)) {
                                            ListItemView(registers: registers, symptoms: symptoms, item: symptom)
                                        }
                                    }
                                    .onDelete { indices in
                                        // Delete the symptoms and its registers
                                        let symptomList = symptoms.sortedFavoriteSymptoms
                                        registers.deleteRegisters(at: indices, from: symptomList)
                                        symptoms.deleteSymptoms(at: indices, from: symptomList)
                                    }
                                }
                            }
                        if !symptoms.sortedNonFavoriteSymptoms.isEmpty {
                                Section("Datos de Salud") {
                                    ForEach(symptoms.sortedNonFavoriteSymptoms) { symptom in
                                        NavigationLink(destination: AnalysisView(analysisViewModel: symptoms.createAnalysisViewModel(for: symptom), registers: registers)) {
                                            ListItemView(registers: registers, symptoms: symptoms, item: symptom)
                                        }
                                    }
                                    .onDelete { indices in
                                        // Delete the symptoms and its registers
                                        let symptomList = symptoms.sortedNonFavoriteSymptoms
                                        registers.deleteRegisters(at: indices, from: symptomList)
                                        symptoms.deleteSymptoms(at: indices, from: symptomList)
                                    }
                                }
                            }
                    }
                    .listRowSpacing(15) // Create a separation between list items
                }
            }
             // Sheet to create a new symptom
            .sheet(isPresented: $showCreateSymptomView) {
                CreateSymptomView(formViewModel: symptoms.createSymptomViewModel())
            }
            .overlay(
                Group {
                    if (symptoms.state == .complete) {
                        Button {
                            showCreateSymptomView = true
                        } label: {
                            Label("Agregar nuevo dato", systemImage: "square.and.pencil")
                        }
                        .buttonStyle(Button1MedTracker(backgroundColor: Color("blueGreen")))
                        .offset(x: -14, y: -55)
                    }
                },
                alignment: .bottomTrailing)
            .overlay(
                Group{
                    if symptoms.state == .complete || symptoms.state == .isLoading {
                        GeometryReader { geometry in
                            Image("logoP")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.3)
                                .position(x: geometry.size.width * 0.24, y: geometry.size.height * -0.03)
                        }
                    }
                },
                alignment: .topTrailing)
            
            .toolbar {
                // Button to traverse to EditSymptomView.
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareButtonView(symptomList: symptoms, registerList: registers)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}


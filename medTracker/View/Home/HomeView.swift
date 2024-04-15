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
    @State private var showEditSymptomView = false
    @State private var showCreateSymptomView = false
    
    
    let testRegisters: [Register] = RegisterList.getDefaultRegisters()
    
    
    
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
                        // Convert dictionary to an array and sort them by date
                        ForEach(symptoms.sortedSymptoms) { symptom in
                            if symptom.isActive {
                                // Show a listItem view and redirect user to analysis upon touching
                                NavigationLink(destination: AnalysisView(symptom: symptom, registers: registers)) {
                                    ListItemView(item: symptom, registers: registers)
                                        .padding(2)
                                }
                            }
                        }
                    }
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
                    Button {
                        showEditSymptomView = true
                    } label: {
                        Text("Editar")
                    }
                }
            }
            // Present full screen the EditSymptomView.
            .fullScreenCover(isPresented: $showEditSymptomView) {
                EditSymptomView(symptoms: symptoms, registers: registers)
            }
        }
    }
}


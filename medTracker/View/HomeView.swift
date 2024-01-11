//
//  pagInicio.swift
//  medTracker
//
//  Created by Alumno on 09/11/23.
//

import SwiftUI

// View que se llama para el menú de compartir en la app
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (_, completed, _, _) in
            onComplete(completed)
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No es necesario actualizar el UIActivityViewController.
    }
}

/**********************
 This view shows all the symptoms being tracked and has the option to add a new symptom or add a data related to a symptom.
 **********************************/
struct HomeView: View {
    @ObservedObject var listaDatos : SymptomList
    @ObservedObject var registers : RegisterList
    @State private var isShowingActivityView = false
    @State private var activityItems: [Any] = []
    @State private var muestraEditarSintomas = false
    @State private var muestraAgregarSintomas = false
    @State private var muestraNewSymptom = false
    @State private var muestraShare = false
    @State private var isHomeViewActive = true
    @State private var isNavigationViewActive = false


    //@State private var refreshID = UUID()
    
    
    var body: some View {
        ZStack{
            NavigationStack {
                VStack {
                    // Show the view based on symptomList state (loading, emptyArray, arrayWithValues).
                    switch listaDatos.state {
                    case .isLoading:
                        ProgressView() //Loading animation
                    case .isEmpty:
                        //Calls a view to show that the symptom list is empty
                        //The action serves as a button to send the user to a page to create a symptom.
                        EmptyListView(
                            title: "No hay datos registrados",
                            message: "Favor de agregar datos para poder empezar a registrar.",
                            nameButton: "Agregar Dato",
                            action: { muestraNewSymptom = true }
                        )
                        // The sheets sends the user to the view to create a new symptom.
                        .sheet(isPresented: $muestraNewSymptom) {
                            AddSymptomView(symptoms: listaDatos, createAction: listaDatos.makeCreateAction())
                        }
                    case .complete:
                        List {
                            ForEach(listaDatos.symptoms.indices, id: \.self) { index in
                                if listaDatos.symptoms[index].activo {
                                    let symptom = listaDatos.symptoms[index]
                                    NavigationLink{
                                        RegisterSymptomView(symptom: $listaDatos.symptoms[index], registers: registers, symptomList: listaDatos, sliderValue : .constant(0.155) ,createAction: registers.makeCreateAction())
                                    }
                                    label: {
                                        Celda(unDato : symptom)
                                    }
                                    .padding(10)
                                    //                                .padding(10)
                                    
                                }
                            }
                        }
                    }
                }
                .overlay(
                    Group {
                        if isHomeViewActive && (listaDatos.state == .complete) {
                            Button {
                                muestraAgregarSintomas = true
                            } label: {
                                Label("Agregar nuevo dato", systemImage: "square.and.pencil")
                            }
                            .buttonStyle(Button1MedTracker(backgroundColor: Color("blueGreen")))
                            .offset(x: -14, y: -95)
                            .sheet(isPresented: $muestraAgregarSintomas) {
                                AddSymptomView(symptoms: listaDatos, createAction: listaDatos.makeCreateAction())
                            }
                        }
                    },
                alignment: .bottomTrailing)
                .navigationTitle("Datos de salud")
                .overlay(
                    Group{
                        if listaDatos.state == .complete || listaDatos.state == .isLoading {
                            GeometryReader { geometry in
                                        Image("logoP")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                                            .position(x: geometry.size.width * 0.24, y: geometry.size.height * -0.1)
                                    }
                        }
                    },
                         alignment: .topTrailing)
                        
                .toolbar {
                    // Button to traverse to EditSymptomView.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if let url = exportCSV() {
                                activityItems = [url]
                                isShowingActivityView = true
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            muestraEditarSintomas = true
                        } label: {
                            Text("Editar")
                        }
                    }
                }
                // Present full screen the EditSymptomView.
                .fullScreenCover(isPresented: $muestraEditarSintomas) {
                    //ShareView(listaDatos: listaDatos, registers: registers)
                    EditSymptomView(listaDatos: listaDatos)
                }
//                .onChange(of: listaDatos.state) { newState in
//                    // Update the isHomeViewActive based on the state of listaDatos
//                    isHomeViewActive = newState != .complete
//                }
                .sheet(isPresented: $muestraAgregarSintomas, content: {
                    AddSymptomView(symptoms: listaDatos, createAction: listaDatos.makeCreateAction())
                    /*.onChange(of: listaDatos.symptoms) { _ in
                     refreshID = UUID()
                     }*/
                })
                .sheet(isPresented: $isShowingActivityView) {
                    ActivityView(activityItems: activityItems, onComplete: { completed in
                        isShowingActivityView = false
                        // Aquí puedes manejar el resultado de la acción de compartir.
                    })
                }
            }
//            }
            
        }
    }
    func exportCSV()-> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let fileName = "Datos.csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        var csvText = "Nombre del Dato,Fecha,Cantidad,Notas\n"
        let sortedRegs = registers.registers.sorted(by: {$0.idSymptom > $1.idSymptom})
        for register in sortedRegs {
            let fechaStr = formatter.string(from:register.fecha)
            if(getSymptomActive(register: register)){
                let newLine = "\(getSymptomName(register: register)),\(fechaStr),\(register.cantidad),\(register.notas)\n"
                csvText.append(contentsOf: newLine)
            }
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootViewController = windowScene.windows.first?.rootViewController {
                    let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error al escribir el archivo CSV: \(error)")
        }
        return path
    }
}
@MainActor func getSymptomName(register : Register)->String{
    @ObservedObject var listaDatos = SymptomList()
    return listaDatos.returnName(id: register.idSymptom)
}

@MainActor func getSymptomActive(register : Register)->Bool{
    @ObservedObject var listaDatos = SymptomList()
    return listaDatos.returnActive(id: register.idSymptom)
}
    
    // Struct to show the respective icon for each symptom.
    struct Celda: View {
        var unDato : Symptom
        
        var body: some View {
            HStack {
                Image(systemName: unDato.icon)
                    .foregroundColor(Color(hex: unDato.color))
                VStack(alignment: .leading) {
                    Text(unDato.nombre)
                        .font(.title2)
                    
                }
            }
        }
    }
    
    struct pagInicio_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(listaDatos: SymptomList(), registers: RegisterList())
        }
    }


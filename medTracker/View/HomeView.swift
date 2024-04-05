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
    @ObservedObject var symptoms : SymptomList
    @ObservedObject var registers : RegisterList
    @State private var isShowingActivityView = false
    @State private var activityItems: [Any] = []
    @State private var muestraEditarSintomas = false
    @State private var muestraAgregarSintomas = false
    @State private var muestraNewSymptom = false
    
    
    let testRegisters: [Register] = [
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
    
    
    
    var body: some View {
        ZStack {
//            NavigationStack {
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
                            action: { muestraNewSymptom = true }
                        )
                        // The sheets sends the user to the view to create a new symptom.
                        .sheet(isPresented: $muestraNewSymptom) {
                            AddSymptomView(symptoms: symptoms, createAction: symptoms.makeCreateAction())
                        }
                    case .complete:
                        List {
                            ForEach(symptoms.symptoms.indices, id: \.self) { index in
                                if symptoms.symptoms[index].activo {
                                    let symptom = symptoms.symptoms[index]
                                    NavigationLink{
                                        RegisterSymptomView(symptom: $symptoms.symptoms[index], registers: registers, symptoms: symptoms, sliderValue : .constant(0.155) ,createAction: registers.makeCreateAction())
                                    }
                                label: {
                                    ListItemView(item: symptom, registers: testRegisters)
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
                        if (symptoms.state == .complete) {
                            Button {
                                muestraAgregarSintomas = true
                            } label: {
                                Label("Agregar nuevo dato", systemImage: "square.and.pencil")
                            }
                            .buttonStyle(Button1MedTracker(backgroundColor: Color("blueGreen")))
                            .offset(x: -14, y: -95)
                            .sheet(isPresented: $muestraAgregarSintomas) {
                                AddSymptomView(symptoms: symptoms, createAction: symptoms.makeCreateAction())
//                                CreateSymptomView(formViewModel: symptoms.createSymptomViewModel())
                            }
                        }
                    },
                    alignment: .bottomTrailing)
                .navigationTitle("Datos de salud")
                .overlay(
                    Group{
                        if symptoms.state == .complete || symptoms.state == .isLoading {
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
                    EditSymptomView(symptoms: symptoms, registers: registers)
                }
                .sheet(isPresented: $isShowingActivityView) {
                    ActivityView(activityItems: activityItems, onComplete: { completed in
                        isShowingActivityView = false
                        // Aquí puedes manejar el resultado de la acción de compartir.
                    })
                }
            }
//        }
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
            if(getSymptomActive(register: register, listaDatos: symptoms)){
                let newLine = "\(getSymptomName(register: register, listaDatos: symptoms)),\(fechaStr),\(register.cantidad),\(register.notas)\n"
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
            customPrint("[HomeView] Error while writing the CSV file: \(error)")
        }
        return path
    }
}
@MainActor func getSymptomName(register : Register, listaDatos: SymptomList)->String{
    @ObservedObject var listaDatos = SymptomList(repository: listaDatos.repository)
    return listaDatos.returnName(id: register.idSymptom)
}

@MainActor func getSymptomActive(register : Register, listaDatos: SymptomList)->Bool{
    @ObservedObject var listaDatos = SymptomList(repository: listaDatos.repository)
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


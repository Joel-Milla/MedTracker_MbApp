//
//  RegistroDatos1.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 18/10/23.
//

import SwiftUI



struct RegisterSymptomView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var mostrarTeclado : Bool
    @Binding var symptom : Symptom
    @State var registers : RegisterList
    @State var symptoms : SymptomList
    @Binding var sliderValue : Double
    @State var metricsString = ""
    @State private var date = Date.now
    @State private var hour = Date.now
    @State var valueFinal:Double = 0
    
    //@State var sliderOrTF : Bool = false
    @State var notes = "Agrega alguna nota..."
    var dummySymptom = "Migraña"
    @State var metric: Double = 0
    @State private var notificacionesActivas = false
    @State var nuevaNotificacion = false
    
    @State var isPresented = false
    
    typealias CreateAction = (Register) async throws -> Void
    let createAction: CreateAction
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .month, value: -6, to: Date())!
        let end = Date()
        return start...end
    }()
    
    
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
                VStack(alignment: .leading) {
                    Text(symptom.nombre)
                        .font(.title)
                        .bold()
                    ZStack{
                        VStack(alignment: .leading){
                            Text("Fecha de registro")
                                .padding(.horizontal)
                                .foregroundStyle(Color(uiColor: .systemGray))
                            DateSection(date: date, hour: hour)
                                .padding()
                            if(!symptom.cuantitativo){
                                CustomSlider(valueFinal: $valueFinal)
                                    .padding(.horizontal, 5)
                                    .frame(height: geometry.size.height * 0.06)
                                    .padding(.vertical, 35)
                            }
                            else{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                        .background(RoundedRectangle(cornerRadius: 20).fill(Color("mainWhite")))
                                        .frame(width: geometry.size.width * 0.63, height: geometry.size.height * 0.1)
                                    
                                    HStack {
                                        Image(systemName: symptom.icon)
                                            .foregroundColor(Color(hex: symptom.color))
                                            .font(.title)
                                            .padding(.leading, geometry.size.width * 0.25)
                                        TextField("", text: $metricsString, prompt: Text("Valor").foregroundColor(.gray))
                                            .font(.title2)
                                            .padding()
                                            .multilineTextAlignment(.leading)
                                            .keyboardType(.numberPad)
                                        //.focused($mostrarTeclado)
                                    }
                                    //.frame(width: geometry.size.width * 0.63, height: geometry.size.height * 0.1)
                                    .padding()
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    //.background(Color("mainGray"))
                    //.shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, geometry.size.width * 0.01)
                    )
                    .padding(.vertical)
                    ZStack{
                        VStack(alignment: .leading){
                            TextField("Agrega alguna nota", text: $notes, axis: .vertical)
                                .lineLimit(5)
                                .padding()
                                .frame(height: geometry.size.height / 6, alignment: .top)
                        }
                        //.padding(.bottom)
                    }
                    //.background(Color("mainGray"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, geometry.size.width * 0.01)
                    )
                    .shadow(radius: 10)
                    //Spacer()
                    Button{
                    }label:{
                        Label("Añadir registro", systemImage: "cross.circle.fill")
                    }
                    .buttonStyle(Button1MedTracker(backgroundColor: Color(hex: symptom.color)))
                    //.frame(height: geometry.size.height *  0.12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                    
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        notificacionesActivas.toggle()
                        // Cambiar el estado de las notificaciones y actualizar la IU
//                        notificacionesActivas.toggle()
//
//                        if notificacionesActivas == false {
//                            cancelNotification(withID: symptom.notificacion ?? "")
//                            symptom.notificacion = ""
//                        } else {
//                            nuevaNotificacion = true
//                        }
                        
                    } label: {
                        Image(systemName: notificacionesActivas ? "bell.fill" : "bell.slash")
                    }
                    
                }
            }
        }
    }
    
    
    private func createRegister() {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await createAction(registers.registers.last ?? Register(idSymptom: "", fecha: Date.now, cantidad: 0, notas: "")) //call the function that adds the symptom to the database
            } catch {
                customPrint("[RegisterSymptomView] Cannot create register: \(error)")
            }
        }
    }
}



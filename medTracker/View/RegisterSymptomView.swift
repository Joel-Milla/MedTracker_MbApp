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
    @ObservedObject var registers : RegisterList
    @ObservedObject var symptoms : SymptomList
    @Binding var sliderValue : Double
    @State var metricsString = ""
    @State private var date = Date.now
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
        GeometryReader { geometry in
            NavigationStack(){
                ZStack {
                    VStack() {
                        Text(symptom.nombre)
                            .font(.title)
                            .foregroundStyle(Color(hex: symptom.color))
                            .bold()
                            .padding(.horizontal, -179)
                            .frame(height: geometry.size.height *  0.06)
                        DatePicker("Fecha registro", selection: $date, in: dateRange,  displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.automatic)
                            .padding(.vertical,30)
                            .foregroundColor(Color(hex: symptom.color))
                            .tint(Color(hex: symptom.color))
                            .bold()
                        //Text("La fecha es \(date.formatted(date: .numeric, time: .shortened))")
                        if(!symptom.cuantitativo){
                            Text("¿Qué tanto malestar tienes?")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: symptom.color))
                                .bold()
                            CustomSlider(valueFinal: $metric, valor: sliderValue)
                                .padding(.horizontal, 5)
                                .frame(height: geometry.size.height * 0.06)
                                .padding(.vertical, 35)
                        }
                        else{
                            Text("Ingresa el valor")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: symptom.color))
                                .bold()
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 0.5)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("mainWhite")))
                                    .frame(width: geometry.size.width * 0.63, height: geometry.size.height * 0.1)
                                
                                HStack {
                                    Image(systemName: "heart.text.square.fill")
                                        .foregroundColor(Color(hex: symptom.color))
                                        .font(.title)
                                    TextField("", text: $metricsString, prompt: Text("Valor").foregroundColor(.gray))
                                        .font(.title2)
                                        .padding()
                                        .textFieldStyle(OvalTextFieldStyle())
                                        .multilineTextAlignment(.leading)
                                        .keyboardType(.numberPad)
                                        .focused($mostrarTeclado)
                                }
                                .padding()
                            }
                        }
                        
                        //Spacer()
                        TextEditor(text: self.$notes) // usar geomtery reader
                            .foregroundColor(self.notes == notes ? .gray : .primary)
                            .onTapGesture {
                                if self.notes == notes {
                                    self.notes = ""
                                }
                            }
                            .padding(10)
                            .cornerRadius(30)
                            .scrollContentBackground(.hidden)
                            .background(Color("mainWhite"))
                            .shadow(color: .gray, radius: 0.5)
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                            .frame(height: geometry.size.height *  0.28)
                            .focused($mostrarTeclado)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    
                                    Button("OK") {
                                        mostrarTeclado = false
                                    }
                                }
                            }
                        Button{
                            if(self.notes == "Agrega alguna nota..."){
                                notes = ""
                            }
                            
                            if symptom.cuantitativo {
                                if let cantidad = Float(metricsString) {
                                    registers.registers.append(Register(idSymptom: symptom.id, fecha: date, cantidad: cantidad, notas: notes))
                                    createRegister()
                                    dismiss()
                                }
                                else{
                                    isPresented = true
                                }
                            } else {
                                registers.registers.append(Register(idSymptom: symptom.id, fecha: date, cantidad: Float(metric), notas: notes))
                                createRegister()
                                dismiss()
                            }
                        }label:{
                            Label("Añadir información", systemImage: "cross.circle.fill")
                        }
                        .alert("Ingresa algún dato para continuar", isPresented: $isPresented, actions: {})
                        .buttonStyle(Button1MedTracker(backgroundColor: Color(hex: symptom.color)))
                        .frame(height: geometry.size.height *  0.12)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    //Spacer()
                    .navigationTitle("Agregar registro")
                    .navigationBarTitleDisplayMode(.inline)
                    
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                // Cambiar el estado de las notificaciones y actualizar la IU
                                notificacionesActivas.toggle()
                                
                                if notificacionesActivas == false {
                                    cancelNotification(withID: symptom.notificacion ?? "")
                                    symptom.notificacion = ""
                                } else {
                                    nuevaNotificacion = true
                                }
                                
                            } label: {
                                Image(systemName: notificacionesActivas ? "bell.fill" : "bell.slash")
                            }
                            
                        }
                    }
                    
                    
                }
            }
            .onAppear {
                notificacionesActivas = symptom.notificacion != ""
            }
            .sheet(isPresented: $nuevaNotificacion) {
                NuevaSintoma(symptom: $symptom, notificacionesActivas: $notificacionesActivas,createAction2: symptoms.makeCreateAction())
                    .presentationDetents([.fraction(0.35)])
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
    private func createRegister() {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await createAction(registers.registers.last ?? Register(idSymptom: 0, fecha: Date.now, cantidad: 0, notas: "")) //call the function that adds the symptom to the database
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
            }
        }
    }
}

struct NuevaSintoma: View {
    var cada_cuanto = ["Todos los días", "Cada semana", "Una vez al mes"]
    @State var notificaciones_seleccion = "Todos los días"
    @State private var selectedFrequency: String = "Todos los días"
    @Binding var symptom : Symptom
    @Binding var notificacionesActivas : Bool
    @State private var selectedDayOfWeek = "Domingo"
    @State private var selectedDate = Date()
    typealias CreateAction2 = (Symptom) async throws -> Void
    let createAction2: CreateAction2
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Añadir notificación")
                .font(.title3.bold())
                .padding(.vertical, 10)
            
            
            Picker("Quiero recibirlas:", selection: $selectedFrequency) {
                ForEach(cada_cuanto, id: \.self) {
                    Text($0)
                    //.foregroundColor(notificaciones ? colorSymptom : Color.gray)
                }
            }
            .pickerStyle(.segmented)
            .foregroundColor(Color(hex: symptom.color))
            .font(.system(size: 18))
            .padding(.bottom, 20)
            
            if selectedFrequency == "Todos los días" {
                HStack{
                    Spacer()
                    DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .padding(.trailing, 20)
                    Spacer()
                }
            } else if selectedFrequency == "Cada semana" {
                HStack{
                    Spacer()
                    Picker("Selecciona el día de la semana", selection: $selectedDayOfWeek) {
                        ForEach(["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"], id: \.self) {
                            Text($0)
                        }
                    }
                    .labelsHidden()
                    .padding(.trailing, 20)
                    
                    DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .padding(.trailing, 20)
                    Spacer()
                }
            } else if selectedFrequency == "Una vez al mes" {
                HStack{
                    Spacer()
                    DatePicker("Selecciona el día del mes", selection: $selectedDate, in: Date()..., displayedComponents: [.date])
                        .labelsHidden()
                        .padding(.trailing, 20)
                    
                    DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .padding(.trailing, 20)
                    Spacer()
                }
            }
            
            Button {
                let notificationIdentifier = scheduleNotification(frecuencia: selectedFrequency, selectedDate: selectedDate, selectedDayOfWeek: selectedDayOfWeek, nombreSintoma: symptom.nombre)
                symptom.notificacion = notificationIdentifier
                modifySymptom(symptomModification: symptom)
                notificacionesActivas = true
                dismiss()
            } label: {
                Label("Añadir notificación", systemImage: "cross.circle.fill")
            }
            .buttonStyle(Button1MedTracker(backgroundColor: Color(hex: symptom.color)))
            .padding()
            
        }
        .onAppear {
            notificacionesActivas = false
        }
        .padding(.horizontal, 20)
    }
    
    private func modifySymptom(symptomModification: Symptom) {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await createAction2(symptomModification) //call the function that adds the symptom to the database
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
            }
        }
    }
}
// To dismiss keyboard on type
extension UIApplication {
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}


struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background((Color("mainWhite")))
        
        /*(LinearGradient(gradient: Gradient(colors: [Color.white, Color("blueGreen").opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))*/
            .cornerRadius(10)
            .frame(width: 150)
    }
}

//
//  newSymptom.swift
//  medTracker
//
//  Created by Alumno on 26/10/23.
//

import SwiftUI
import SegmentedPicker

struct DateUtils {
    static func weekdayFromString(_ weekdayString: String) -> Int? {
        switch weekdayString {
        case "Domingo": return 1
        case "Lunes": return 2
        case "Martes": return 3
        case "Miércoles": return 4
        case "Jueves": return 5
        case "Viernes": return 6
        case "Sábado": return 7
        default: return nil
        }
    }
}


struct AddSymptomView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedDayOfWeek = "Domingo"
    @State var nombreSintoma = ""
    @State var descripcion = ""
    @State private var colorSymptom = Color.blue
    @State private var colorString = ""
    @State var notificaciones = false
    @State private var icon = "plus.viewfinder"
    @State private var isPresented = false
    @State var selectedIndex: Int?
    @State var mostrarAlerta = false
    @State var mensajeAlerta = ""
    @State var cuantitativo = 0
    var cada_cuanto = ["Todos los días", "Cada semana", "Una vez al mes"]
    @State var notificaciones_seleccion = "Todos los días"
    @ObservedObject var symptoms : SymptomList
    @State private var selectedFrequency: String = "Todos los días" 
    
    typealias CreateAction = (Symptom) async throws -> Void
    let createAction: CreateAction
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        TextField("Dato de salud", text: $nombreSintoma)
                            .disableAutocorrection(true)
                            .font(.system(size: 28))
                            .foregroundColor(colorSymptom)
                            .submitLabel(.done)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("blueGreen"), lineWidth: 1)
                            )
                        
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: icon).font(.title)
                                .foregroundColor(colorSymptom)
                        }
                        .sheet(isPresented: $isPresented, content: {
                            SymbolsPicker(selection: $icon, title: "Choose your symbol", autoDismiss: true)
                        }).padding()
                        
                        ColorPicker("", selection: $colorSymptom)
                            .labelsHidden()
                            .padding(.trailing, 20)
                    }
                    .padding(.top, 20)

                    TextField("Descripción del dato de salud", text: $descripcion)//, axis : .vertical)
                        .font(.system(size: 18))
                        .textFieldStyle(.roundedBorder)
                        .lineSpacing(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("blueGreen"), lineWidth: 1)
                        )
                        .padding(.trailing, 20)
                        .foregroundColor(colorSymptom)
                        .disableAutocorrection(true)
                        .submitLabel(.done)

                    Picker("Sintoma cuantitativo o cualitativo?", selection: $cuantitativo) {
                                    Text("Cuantitativo").tag(0)
                                    Text("Cualitativo").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Recibir notificaciones", isOn: $notificaciones)
                        .tint(colorSymptom)
                        .padding(.trailing, 20)
                        .padding(.top, 40)
                        .font(.system(size: 24))
                    
                    if notificaciones {
                        Picker("Quiero recibirlas:", selection: $selectedFrequency) {
                            ForEach(cada_cuanto, id: \.self) {
                                Text($0)
                                //.foregroundColor(notificaciones ? colorSymptom : Color.gray)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(!notificaciones ? true : false)
                        //.foregroundColor(notificaciones ? colorSymptom)
                        .padding(.trailing, 20)
                        .font(.system(size: 18))
                        
                        if selectedFrequency == "Todos los días" {
                            HStack{
                                Spacer()
                                DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .padding(.trailing, 20)
                                    .disabled(!notificaciones ? true : false)
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
                                .disabled(!notificaciones ? true : false)
                                
                                DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .padding(.trailing, 20)
                                    .disabled(!notificaciones ? true : false)
                                Spacer()
                            }
                        } else if selectedFrequency == "Una vez al mes" {
                            HStack{
                                Spacer()
                                DatePicker("Selecciona el día del mes", selection: $selectedDate, in: Date()..., displayedComponents: [.date])
                                    .labelsHidden()
                                    .disabled(!notificaciones ? true : false)
                                    .padding(.trailing, 20)
                                
                                DatePicker("Selecciona la hora", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .padding(.trailing, 20)
                                    .disabled(!notificaciones ? true : false)
                                Spacer()
                            }
                        }
                    }
                    
                    HStack {
                        Button {
                            if nombreSintoma == "" ||
                                descripcion == "" {
                                mensajeAlerta = "Uno de los campos de textos se ha quedado vacío."
                                mostrarAlerta = true
                            } else if nombreUnico(nombre: nombreSintoma) {
                                mensajeAlerta = "Ya existe un dato con el mismo nombre."
                                mostrarAlerta = true
                            } else {
                                var notificationIdentifier = ""
                                if notificaciones {
                                    notificationIdentifier = scheduleNotification(frecuencia: selectedFrequency, selectedDate: selectedDate, selectedDayOfWeek: selectedDayOfWeek, nombreSintoma: nombreSintoma)
                                }
                                let cuantitativo = selectedIndex == 0 ? true : false
                                symptoms.symptoms.append(Symptom(nombre: nombreSintoma, icon: icon, description: descripcion, cuantitativo: cuantitativo, unidades: "", activo: true, color: colorString, notificacion: notificationIdentifier))
                                createSymptom()
                                dismiss()
                            }
                        } label: {
                            Text("Crear dato")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .alert("Error", isPresented: $mostrarAlerta) {
                            Button("OK") {}
                        }
                        message: {
                            Text(mensajeAlerta)
                        }
                        .padding(.top, 50)
                    }
                }
                .keyboardToolbar()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 20)
                .navigationBarTitle("Agregar dato de salud")
                .ignoresSafeArea(.keyboard)
            }
        }
        .onAppear {
            // Initialize hexString with the initial color
            colorString = hexString(from: colorSymptom)
        }
        .onChange(of: colorSymptom) { newColor in
            // Update hexString when the color changes
            colorString = hexString(from: newColor)
        }
        .background(Color("mainWhite"))
    }
    
    
    private func createSymptom() {
        // will wait until the createAction(symptom) finishes
        Task {
            do {
                try await createAction(symptoms.symptoms.last ?? Symptom(nombre: "", icon: "", description: "", cuantitativo: true, unidades: "", activo: true, color: "", notificacion: "")) //call the function that adds the symptom to the database
            } catch {
                customPrint("[AddSymptomView] Cannot create symptom: \(error)")
            }
        }
    }
    
    func nombreUnico(nombre: String) -> Bool {
        for sympt in symptoms.symptoms {
            if sympt.nombre == nombre {
                return true
            }
        }
        return false
    }
    
    func hexString(from color: Color) -> String {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(color)
        
        // Get the RGBA components
        guard let components = uiColor.cgColor.components else {
            return ""
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        // Convert the components to HEX
        let hexString = String(
            format: "#%02lX%02lX%02lX",
            lroundf(red * 255),
            lroundf(green * 255),
            lroundf(blue * 255)
        )
        
        return hexString
    }
}

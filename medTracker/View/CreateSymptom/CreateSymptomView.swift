//
//  AddSymptomView2_0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 24/03/24.
//

import SwiftUI

struct CreateSymptomView: View {
    // All possible units for quantitative symptoms
    let units = [
        "kg", // Kilogramos
        "lb", // Libras
        "cm", // Centímetros
        "m",  // Metros
        "mmHg", // Milímetros de mercurio (presión arterial)
        "L",  // Litros (para líquidos)
        "mL", // Mililitros
        "pasos", // Pasos
        "cal", // Calorías
        "kcal", // Kilocalorías
        "bpm", // Latidos por minuto (frecuencia cardíaca)
        "mg/dL", // Miligramos por decilitro (glucosa en sangre)
        "°C", // Grados Celsius
        "°F", // Grados Fahrenheit
        "h",  // Horas (para sueño o actividades)
        "min", // Minutos
        "seg", // Segundos
        "%",  // Porcentaje (para saturación de oxígeno, por ejemplo)
        "tazas", // Tazas (volumen para líquidos)
        "g",  // Gramos
    ]
    
    // Variables that hold values of the new symptom
    @State var name: String = ""
    @State var selectedIcon: String = "heart"
    @State var selectedColor: Color = Color("blueGreen")
    @State var description: String = ""
    @State var cuantitativo: Bool = true
    @State var selectedUnit: String = "kg"
    @State var allowNotifications: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre del Dato", text: $name)
                        .disableAutocorrection(true)
                        .textContentType(.username)
                    IconColorView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
                }
                // Description of the new symptom
                Section(header: Text("Descripción")) {
                    Text("Describe el dato")
                    TextEditor(text: $description)
                }
                // Choose the type of symptom
                Section(header: HelpView(title: "Tipo de dato")) {
                    // Use animation to show nicely the new section
                    Picker("Sintoma cuantitativo o cualitativo?", selection: $cuantitativo.animation()) {
                        Text("Cuantitativo").tag(true)
                        Text("Cualitativo").tag(false)
                    }
                    .pickerStyle(.segmented)
                    // Show the view to select the new units
                    if (cuantitativo) {
                        Picker("Unidad", selection: $selectedUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .tint(Color("blueGreen"))
                    }
                }
                
                Section(header: Text("Notificaciones")) {
                    // Use animation to show the new view nicely
                    Toggle(isOn: $allowNotifications.animation()) {
                        Text("Permitir Notificaciones")
                    }
                    // Show the view to select the notification
                    if (allowNotifications) {
                        ConfigureNotificationsView()
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Text("Guardar")
                            .gradientTextStyle() // apply gradient style
                    }
                    .frame(maxWidth: .infinity) // center the text
                    .listRowBackground(Color.clear) // Makes the row background transparent
                }
            }
            .navigationTitle("Crear Dato")
        }
    }
}


#Preview {
    CreateSymptomView()
}

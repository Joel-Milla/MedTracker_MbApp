//
//  CS_TypeView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct CS_TypeView: View {
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
        "otro",
    ]
    // Variables to save
    @Binding var cuantitativo: Bool
    @Binding var selectedUnit: String
    @State var typeUnit: String = "kg"
    // Variables for when the user is using a custom unit
    @State var customUnit: String = ""
    @State private var isCustomUnitActive: Bool = false
    
    var body: some View {
        // Use animation to show nicely the new section
        Picker("Sintoma cuantitativo o cualitativo?", selection: $cuantitativo.animation()) {
            Text("Cuantitativo").tag(true)
            Text("Cualitativo").tag(false)
        }
        .pickerStyle(.segmented)
        // Show the view to select the new units
        if (cuantitativo) {
            Picker("Unidad", selection: $typeUnit.animation()) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }
            .tint(Color("blueGreen"))
            // Save the value of type unit as the value of selectedUnit
            .onAppear(perform: {
                typeUnit = selectedUnit
            })
            // Use on change to save the unit that the user selected to the main variable
            .onChange(of: typeUnit) { newValue in
                // If the user selected "otro" then it needs to pay attention to custom unit
                if (!(newValue == "otro")) {
                    selectedUnit = typeUnit
                }
            }
        }
        // If the unit wasnt defined
        if (typeUnit == "otro") {
            TextField("Escribe tu unidad", text: $customUnit)
            // OnChange so when the user has a typeUnit of otro, to save that value into selected unit
                .onChange(of: customUnit) { newValue in
                    if (typeUnit == "otro") {
                        selectedUnit = newValue
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        @State var cuantitativo: Bool = true
        @State var selectedUnit: String = "kg"
        CS_TypeView(cuantitativo: $cuantitativo, selectedUnit: $selectedUnit)
    }
}

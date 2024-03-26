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
    @State var cuantitativo: Bool = true
    @State var selectedUnit: String = "kg"
    @State var customUnit: String = ""
    
    var body: some View {
        // Use animation to show nicely the new section
        Picker("Sintoma cuantitativo o cualitativo?", selection: $cuantitativo.animation()) {
            Text("Cuantitativo").tag(true)
            Text("Cualitativo").tag(false)
        }
        .pickerStyle(.segmented)
        // Show the view to select the new units
        if (cuantitativo) {
            Picker("Unidad", selection: $selectedUnit.animation()) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }
            .tint(Color("blueGreen"))
        }
        // If the unit wasnt defined
        if (selectedUnit == "otro") {
            TextField("Escribe tu unidad", text: $customUnit)
        }
    }
}

#Preview {
    CS_TypeView()
}

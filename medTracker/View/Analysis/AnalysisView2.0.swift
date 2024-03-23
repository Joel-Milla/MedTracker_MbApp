//
//  AnalysisView2.0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 20/03/24.
//

import SwiftUI

struct AnalysisView2_0: View {
    let symptomTest = Symptom(nombre: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", cuantitativo: true, unidades: "kg", activo: true, color: "#007AFF", notificacion: "")
    
    let testRegisters: [Register] = [
        Register(idSymptom: "SYM-571", fecha: Date(), cantidad: 8.51, notas: "Note 66"),
        Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-32400), cantidad: 8.92, notas: "Note 40"),
        Register(idSymptom: "SYM-603", fecha: Date().addingTimeInterval(-86400 * 1), cantidad: 8.92, notas: "Note 40"),
        Register(idSymptom: "SYM-358", fecha: Date().addingTimeInterval(-86400 * 2), cantidad: 1.36, notas: "Note 25"),
        Register(idSymptom: "SYM-797", fecha: Date().addingTimeInterval(-86400 * 3), cantidad: 7.07, notas: "Note 68"),
        Register(idSymptom: "SYM-936", fecha: Date().addingTimeInterval(-86400 * 4), cantidad: 9.86, notas: "Note 33"),
        Register(idSymptom: "SYM-781", fecha: Date().addingTimeInterval(-86400 * 5), cantidad: 3.29, notas: "Note 77"),
        Register(idSymptom: "SYM-272", fecha: Date().addingTimeInterval(-86400 * 6), cantidad: 9.24, notas: "Note 10"),
        Register(idSymptom: "SYM-158", fecha: Date().addingTimeInterval(-86400 * 7), cantidad: 5.29, notas: "Note 90"),
        Register(idSymptom: "SYM-739", fecha: Date().addingTimeInterval(-86400 * 8), cantidad: 2.67, notas: "Note 46"),
        Register(idSymptom: "SYM-342", fecha: Date().addingTimeInterval(-86400 * 9), cantidad: 5.2, notas: "Note 21"),
        Register(idSymptom: "SYM-343", fecha: Date().addingTimeInterval(-86400 * 10), cantidad: 5.2, notas: "Note 22"),
        Register(idSymptom: "SYM-344", fecha: Date().addingTimeInterval(-86400 * 11), cantidad: 5.2, notas: "Note 23"),
        Register(idSymptom: "SYM-345", fecha: Date().addingTimeInterval(-86400 * 12), cantidad: 22, notas: "Note 24"),
        Register(idSymptom: "SYM-346", fecha: Date().addingTimeInterval(-86400 * 13), cantidad: 5.2, notas: "Note 25"),
        Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 14), cantidad: 9, notas: "Note 29"),
        Register(idSymptom: "SYM-347", fecha: Date().addingTimeInterval(-86400 * 56), cantidad: 3.4, notas: "Note 30")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                LineChartView(symptomTest: symptomTest, testRegisters: testRegisters)
                
                InsightsView(testRegisters: testRegisters)
                
                NavigationLink {
                    registersView()
                } label: {
                    Text("Registros Pasados")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 250)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(symptomTest.nombre)
            // MARK: Simplify updating values for segmented tabs
            .toolbar {
                // Button to traverse to EditSymptomView.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Hello world!")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

extension [Register] {
    // Filter an array of registers by tags.
    func filterBy(_ filter: String) -> [Register] {
        switch(filter) {
        case "Semana":
            // Date of last seven days
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return self.filter({ register in
                register.fecha > sevenDaysAgo
            })
        case "Mes":
            // Date of last seven days
            let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            return self.filter({ register in
                register.fecha > monthAgo
            })
        case "Todos":
            return self
        default:
            return self
        }
    }
}

extension Float {
    // Function to write the cantidad of a register in a nice format
    func asString() -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            // It's an integer, show without decimal places
            return String(format: "%.0f", self)
        } else {
            // It's not an integer, show with up to two decimal places
            return String(format: "%.2f", self).replacingOccurrences(of: ".00", with: "")
        }
    }
}

extension Date {
    // Returns the date as a string on Format MM d - h:m
    func dateToStringMDH() -> String {
        let formatter = DateFormatter()
        // Include abbreviated month name, day, hour, and minute
        formatter.dateFormat = "MMM d - H:mm" // Example: "Feb 23 - 15:14"
        formatter.locale = Locale(identifier: "es_MX") // Spanish month abbreviations
        return formatter.string(from: self)
    }
    
    // Returns the date as a string on format MM d
    func dateToStringMD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Example: "feb 23"
        formatter.locale = Locale(identifier: "es_MX") // Keep for Spanish month abbreviations
        return formatter.string(from: self)
    }
}

#Preview {
    
    NavigationStack {
        AnalysisView2_0()
    }
}


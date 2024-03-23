//
//  AnalysisView2.0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 20/03/24.
//

import SwiftUI
import Charts

struct AnalysisView2_0: View {
    let symptomTest = Symptom(nombre: "Insomnio", icon: "44.square.fill", description: "How well did i sleep", cuantitativo: true, unidades: "kg", activo: true, color: "#007AFF", notificacion: "")
    
    let testRegisters: [Register] = [
        Register(idSymptom: "SYM-571", fecha: Date(), cantidad: 8.51, notas: "Note 66"),
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
    
    // MARK: View Properties
    @State var currentTab: String = "Semana"
    // MARK: Gesture Properties
    @State var currentActiveItem: Register?
    @State var plotWidth: CGFloat = 0
    @State var isLineGraph: Bool = false
    
    @State private var filteredRegisters: [Register] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: New Chart API
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Valores")
                            .fontWeight(.semibold)
                        Picker("", selection: $currentTab) {
                            Text("Semana")
                                .tag("Semana")
                            Text("Mes")
                                .tag("Mes")
                            Text("Todos")
                                .tag("Todos")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 80)
                    }
                    
                    AnimatedCharts()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 2)))
                }
                
                Toggle("Line Graph", isOn: $isLineGraph)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle(symptomTest.nombre)
            // MARK: Simplify updating values for segmented tabs
            .onChange(of: currentTab) { newValue in
                filteredRegisters = testRegisters.filterBy(currentTab)
                if newValue != "Semana" {
                    for (index, _) in filteredRegisters.enumerated() {
                        filteredRegisters[index].animate = false
                    }
                }
                // Re-Animating View
                animateGraph(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedCharts() -> some View {
        let max = filteredRegisters.max { item1, item2 in
            return item2.cantidad > item1.cantidad
        }?.cantidad ?? 0
        
        //        let buffer = TimeInterval(50 * 50 * 2) // One hour buffer
        //        let minHour = sampleAnalytics.map { $0.hour }.min() ?? Date()
        //        let maxHour = sampleAnalytics.map { $0.hour }.max() ?? Date()
        
        
        
        Chart {
            ForEach(filteredRegisters) { register in
                // MARK: Line Graph
                LineMark(
                    x: .value("Fecha", register.fecha, unit: .day),
                    y: .value("Cantidad", register.animate ? register.cantidad : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Fecha", register.fecha, unit: .day),
                    y: .value("Cantidad", register.animate ? register.cantidad : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
                
                // Point Mark
                PointMark(
                    x: .value("Fecha", register.fecha, unit: .day),
                    y: .value("Cantidad", register.animate ? register.cantidad : 0)
                )
                .symbol(Circle().strokeBorder())
                .foregroundStyle(Color(hex: symptomTest.color)) // Color of point mark
                // MARK: Rule Mark for currently dragging item
                if let currentActiveItem, currentActiveItem.id.uuidString == register.id.uuidString {
                    RuleMark(x: .value("Fecha", currentActiveItem.fecha))
                    // Dotted style
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [3], dashPhase: 5))
                    // MARK: Setting in middle of each bars
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text((currentActiveItem.fecha.dateToString()))
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                Text((currentActiveItem.cantidad.asString()))
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
                
            }
        }
        // mark: Customizing x and y axis length
        //        .chartXScale(domain: minHour...maxHour.addingTimeInterval(buffer))
        .chartYScale(domain: 0...(max + max)) // bigger number, smaller the bar charts
        //        // MARK: Gesture to highlight current bar
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // MARK: Getting Current Location
                                let location = value.location
                                // Extracting value from the location
                                // swift charts gives the direct ability to do that
                                // were going to extract the date in a-axis then with the help of that date value were extracting the current item
                                
                                // dont forget to includ the perfect data type
                                if let date: Date = proxy.value(atX: location.x) {
                                    // Extracting the closes register
                                    if let closestRegister = filteredRegisters.min(by: { abs($0.fecha.timeIntervalSince(date)) < abs($1.fecha.timeIntervalSince(date)) }) {
                                        currentActiveItem = closestRegister
                                        plotWidth = proxy.plotAreaSize.width
                                        // Additional logic here to clamp the position of currentActiveItem if necessary
                                    }
                                }
                            }.onEnded { _ in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            filteredRegisters = testRegisters.filterBy(currentTab)
            animateGraph()
        }
    }
    
    // MARK: Animating Graph
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in filteredRegisters.enumerated() {
            // For some reasong delay is not working, using dispatch queue delay
            // animation is for showing a good graph
            withAnimation(fromChange ? .easeInOut(duration: 0.6) : .easeInOut(duration: 1)) {
                filteredRegisters[index].animate = true
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
    // Returns the date as a string on Format MM/dd
    func dateToString() -> String {
        let formatter = DateFormatter()
        // Use "MMMM d" for the full name of the month, or "MMM d" for the abbreviated name.
        formatter.dateFormat = "d 'de' MMMM" // Example: "1 de enero"
        formatter.locale = Locale(identifier: "es_MX") // Set locale to Mexican Spanish
        return formatter.string(from: self)
    }
}

#Preview {
    
    NavigationStack {
        AnalysisView2_0()
    }
}


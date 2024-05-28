//
//  BloodPressureChartView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 27/05/24.
//

import SwiftUI
import Charts

struct BloodPressureChartView: View {
    // Variables to show information
    @State var symptom: Symptom
    @ObservedObject var registers: RegisterList
    // MARK: View Properties
    @State var currentTab: String = "Semana"
    @State var isLineGraph: Bool = true
    
    var body: some View {
        // MARK: Chart API
        // Show the information from the chart and different tab buttons
        VStack(spacing: 12) {
            // Picker to switch the time-zone of data shown
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
                .padding(.leading, 50)
            }
            BPLineChartView(symptom: symptom, registers: registers, currentTab: $currentTab)
            
        }
        .padding() // Apply padding to content directly
        .borderStyle()
    }
}


struct BPLineChartView: View {
    // Variables to show information
    let symptom: Symptom
    @ObservedObject var registers: RegisterList
    // MARK: View Properties
    @Binding var currentTab: String
    @State var filteredSystolicRegisters: [Register] = []
    @State var filteredDystolicRegisters: [Register] = []
    // MARK: Gesture Properties
    @State var currentActiveItem: Register?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        // MARK: Chart that changes when the currentTab (time zone selected changes)
        AnimatedCharts()
            .onAppear {
                filterRegisters()
            }
            .onChange(of: currentTab) { newValue in
                filterRegisters()
            }
        // This onChange will trigger the graph to update when a new register is created
            .onChange(of: registers.registers) { _ in
                filterRegisters()
            }
    }
    
    @ViewBuilder
    func AnimatedCharts() -> some View {
        // Max value to extend the y-scale of the data
        let max = filteredSystolicRegisters.max { item1, item2 in
            return item2.amount > item1.amount
        }?.amount ?? 0
        // Values to block the x scale from moving
        let minDate = filteredSystolicRegisters.first?.date ?? Date.now
        let maxDate = filteredSystolicRegisters.last?.date ?? Date.now
        
        Chart {
            ForEach(filteredSystolicRegisters.indices, id: \.self) { index in
                let systolic = filteredSystolicRegisters[index]
                let diastolic = filteredDystolicRegisters[index]
                
                LineMark(
                    x: .value("Day", systolic.date),
                    y: .value("Systolic BP", systolic.amount),
                    series: .value("Type", "Systolic")
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.red.gradient)
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Day", systolic.date),
                    y: .value("Diastolic BP", diastolic.amount),
                    series: .value("Type", "Diastolic")
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
            }
            
//            ForEach(filteredSystolicRegisters) { register in
//                // MARK: Line Graph
//                LineMark(
//                    x: .value("Fecha", register.date),
//                    y: .value("Cantidad", register.animate ? register.amount : 0)
//                )
//                // Applying Gradient Style
//                // From swiftui 4.0 can direclty create gradient color
//                .foregroundStyle(.blue.gradient)
//                .interpolationMethod(.catmullRom)
//                // Show an area mark under the line graph
//                AreaMark(
//                    x: .value("Fecha", register.date),
//                    y: .value("Cantidad", register.animate ? register.amount : 0)
//                )
//                // Applying Gradient Style
//                // From swiftui 4.0 can direclty create gradient color
//                .foregroundStyle(.blue.opacity(0.1).gradient)
//                .interpolationMethod(.catmullRom)
//                
//                // Point Mark to show where the value exists.
//                PointMark(
//                    x: .value("Fecha", register.date),
//                    y: .value("Cantidad", register.animate ? register.amount : 0)
//                )
//                .symbol(Circle().strokeBorder())
//                .foregroundStyle(.red) // Color of point mark
//                
//                // MARK: Rule Mark for currently dragging item
//                // The current item is choosen when the user makes a drag motion.
//                if let currentActiveItem, currentActiveItem.id.uuidString == register.id.uuidString {
//                    // Add a rule on the x value on the graph
//                    RuleMark(
//                        x: .value("Fecha", register.date)
//                        //                        yStart: .value("Min", 0),
//                        //                        yEnd: .value("Cantidad", currentActiveItem.cantidad)
//                    )
//                    // Add an annotation on top of the vertical line to show the value of the nearest item
//                    .annotation(position: .top) {
//                        AnnotationView(symptom: symptom, register: currentActiveItem, minDate: minDate, maxDate: maxDate)
//                    }
//                }
//            }
        }
        // MARK: Customizing x and y axis length
//        .chartXScale(domain: minDate...maxDate)
        .chartYScale(domain: 0...(1.5 * max)) // bigger number, smaller the bar charts
        // MARK: Customizing y axis labels
        .chartYAxis {
            AxisMarks() // Default behavior for quantitative data
        }
        // MARK: Gesture to highlight current bar.
        // Uses drag gesture and calculate the nearest x value on the graph
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
                                    // Extracting the closest register
                                    if let closestRegister = filteredSystolicRegisters.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                                        currentActiveItem = closestRegister // set the closes register globally to put marks on there
                                    }
                                }
                            }.onEnded { _ in
                                self.currentActiveItem = nil // when drag gesture ends, reset the current item
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            filterRegisters()
        }
    }
    
    // Function to update the filteredRegisters
    func filterRegisters() {
        filteredSystolicRegisters = registers.registers[HelperFunctions.zeroOneOneUUID.uuidString]?.filterBy(currentTab) ?? []
        filteredDystolicRegisters = registers.registers[HelperFunctions.zeroOneUUID.uuidString]?.filterBy(currentTab) ?? []
        
        print(registers.registers[HelperFunctions.zeroOneOneUUID.uuidString]!)
        print(registers.registers[HelperFunctions.zeroOneOneUUID.uuidString]?.filterBy(currentTab))
    }
}

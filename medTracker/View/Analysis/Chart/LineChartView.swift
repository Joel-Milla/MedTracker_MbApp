//
//  LineChartView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import SwiftUI
import Charts

struct LineChartView: View {
    // Variables to show information
    let symptom: Symptom
    @ObservedObject var registers: RegisterList
    // MARK: View Properties
    @Binding var currentTab: String
    @State var filteredRegisters: [Register] = []
    // MARK: Gesture Properties
    @State var currentActiveItem: Register?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        // MARK: Chart that changes when the currentTab (time zone selected changes)
        AnimatedCharts()
            .onChange(of: currentTab) { newValue in
                filterRegisters()
                // Re-Animating View
                animateGraph(fromChange: true)
            }
        // This onChange will trigger the graph to update when a new register is created
            .onChange(of: registers.registers) { _ in
                filterRegisters()
                // Re-Animating View
                animateGraph()
            }
    }
    
    @ViewBuilder
    func AnimatedCharts() -> some View {
        // Max value to extend the y-scale of the data
        let max = filteredRegisters.max { item1, item2 in
            return item2.amount > item1.amount
        }?.amount ?? 0
        // Values to block the x scale from moving
        let minDate = filteredRegisters.first?.date ?? Date.now
        let maxDate = filteredRegisters.last?.date ?? Date.now
        
        Chart {
            ForEach(filteredRegisters) { register in
                // MARK: Line Graph
                LineMark(
                    x: .value("Fecha", register.date),
                    y: .value("Cantidad", register.animate ? register.amount : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
                // Show an area mark under the line graph
                AreaMark(
                    x: .value("Fecha", register.date),
                    y: .value("Cantidad", register.animate ? register.amount : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
                
                // Point Mark to show where the value exists.
                PointMark(
                    x: .value("Fecha", register.date),
                    y: .value("Cantidad", register.animate ? register.amount : 0)
                )
                .symbol(Circle().strokeBorder())
                .foregroundStyle(.red) // Color of point mark
                
                // MARK: Rule Mark for currently dragging item
                // The current item is choosen when the user makes a drag motion.
                if let currentActiveItem, currentActiveItem.id.uuidString == register.id.uuidString {
                    // Add a rule on the x value on the graph
                    RuleMark(
                        x: .value("Fecha", register.date)
                        //                        yStart: .value("Min", 0),
                        //                        yEnd: .value("Cantidad", currentActiveItem.cantidad)
                    )
                    // Add an annotation on top of the vertical line to show the value of the nearest item
                    .annotation(position: .top) {
                        Annotation(symptom: symptom, register: currentActiveItem, minDate: minDate, maxDate: maxDate)
                    }
                }
            }
        }
        // MARK: Customizing x and y axis length
        .chartXScale(domain: minDate...maxDate)
        .chartYScale(domain: 0...(1.5 * max)) // bigger number, smaller the bar charts
        // Add the y axis labels when the symptom is Quantitaitve
        .chartYAxis {
            if (!symptom.isQuantitative) {
                AxisMarks(preset: .aligned, position: .trailing, values: .stride(by: 50)) { value in
                    if let yValue = value.as(Double.self) {
                        AxisGridLine() // Show the grid line on the y axis
                        AxisValueLabel {
                            // On values 0-50-100 show images instead of numbers
                            switch yValue {
                            case 0:
                                Image("sadder_face")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                            case 50:
                                Image("sad_face")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                            case 100:
                                Image("happier_face")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                            default:
                                Text("")
                            }
                        }
                    }
                }
            } else {
                AxisMarks() // Default behavior for quantitative data
            }
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
                                    if let closestRegister = filteredRegisters.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
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
            animateGraph()
        }
    }
    
    // Function to update the filteredRegisters
    func filterRegisters() {
        filteredRegisters = registers.registers[symptom.id.uuidString]?.filterBy(currentTab) ?? []
    }
    
    // MARK: Function to animate the graph
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in filteredRegisters.enumerated() {
            // animation is for showing a good graph
            withAnimation(fromChange ? .easeInOut(duration: 0.6) : .easeInOut(duration: 1)) {
                filteredRegisters[index].animate = true
            }
        }
    }
}

//MARK: View to show an annotation depending if the symptom is quant or qual
struct Annotation: View {
    let symptom: Symptom
    let register: Register
    
    let minDate: Date
    let maxDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Show the date of the current value and the value
            Group {
                if (symptom.isQuantitative) {
                    Text(register.date.dateToStringMDH())
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(register.amount.asString())
                        .font(.title3.bold())
                } else {
                    Text(register.date.dateToStringMDH())
                        .font(.caption)
                        .foregroundStyle(.gray)
                    // Obtain the image of the current value selected and show it
                    let imageName = HelperFunctions.getImage(of: register.amount)
                    HStack {
                        Spacer()
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.white.shadow(.drop(radius: 2)))
        }
        // Move the annotation when it is on the corners so the annotation shows clearly and not on borders
        .offset(x: register.date.dateToStringMDH() == minDate.dateToStringMDH() ? 35 : register.date.dateToStringMDH() == maxDate.dateToStringMDH() ? -20 : 0)
    }
}

#Preview {
    NavigationStack {
        @State var repository = Repository(user: User(id: "3zPDb70ofQQHximl1NXwPMgIhMR2", rol: "Paciente", email: "joel@mail.com", phone: "", name: "Joel", clinicalHistory: "", sex: "", birthdate: Date.now, height: "", doctors: ["doc@mail.com"]))
        @State var registers: RegisterList = RegisterList(repository: repository)
        
        let symptom = Symptom(name: "", icon: "heart", description: "", isQuantitative: true, units: "kg", isActive: true, color: "#000000", notification: "")
        
        @State var currentTab: String = "Semana"
        
        LineChartView(symptom: symptom, registers: registers, currentTab: $currentTab)
    }
}

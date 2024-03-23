//
//  BarChartView_Cual.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 23/03/24.
//
import SwiftUI
import Charts

struct BarChartView_Cual: View {
    // Mock data
    let testRegisters: [Register]
    // MARK: View Properties
    @Binding var currentTab: String
    @State var filteredRegisters: [Register] = []
    // MARK: Gesture Properties
    @State var currentActiveItem: Register?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        // MARK: Line Chart API
        AnimatedCharts()
            .onChange(of: currentTab) { newValue in
                filteredRegisters = testRegisters.filterBy(currentTab)
                // Re-Animating View
                animateGraph(fromChange: true)
            }
    }
    
    @ViewBuilder
    func AnimatedCharts() -> some View {
        // Values to block the x scale from moving
        let minDate = filteredRegisters.adjustDatesToStartOfDay().map { $0.fecha }.min() ?? Date()
        let maxDate = filteredRegisters.adjustDatesToStartOfDay().map { $0.fecha }.max() ?? Date()
        
        Chart {
            ForEach(filteredRegisters) { register in
                // MARK: Bar Graph
                BarMark(
                    x: .value("Fecha", register.adjustDateToDay().fecha, unit: .day),
                    y: .value("Cantidad", register.animate ? register.cantidad : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.gradient)
                
                // MARK: Rule Mark for currently dragging item
                if let currentActiveItem, currentActiveItem.id.uuidString == register.id.uuidString {
                    RuleMark(x: .value("Fecha", currentActiveItem.adjustDateToDay().fecha))
                    // Dotted style
                    // MARK: Setting in middle of each bars
                        .offset(x: (plotWidth / CGFloat(filteredRegisters.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(currentActiveItem.fecha.dateToStringMDH())
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                let imageName = HelperFunctions.getImage(of: currentActiveItem.cantidad)
                                HStack {
                                    Spacer()
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                            // Move the annotation when it is on the corners
                            .offset(x: currentActiveItem.fecha.dateToStringMDH() == minDate.dateToStringMDH() ? 35 : currentActiveItem.fecha.dateToStringMDH() == maxDate.dateToStringMDH() ? -20 : 0)
                        }
                }
            }
        }
        // hard code the scale
        .chartXScale(domain: minDate...maxDate.addingTimeInterval(86400))
        // MARK: Customizing x and y axis length
        .chartYScale(domain: [0, 150]) // bigger number, smaller the bar charts
        .chartYAxis {
            AxisMarks(preset: .aligned, position: .trailing, values: .stride(by: 50)) { value in
                if let yValue = value.as(Double.self) {
                    AxisGridLine()
                    AxisValueLabel {
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
        }
        // MARK: Gesture to highlight current bar
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
                                    if let closestRegister = filteredRegisters.min(by: { abs($0.fecha.timeIntervalSince(date)) < abs($1.fecha.timeIntervalSince(date)) }) {
                                        self.currentActiveItem = closestRegister
                                        self.plotWidth = proxy.plotAreaSize.width

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
            // animation is for showing a good graph
            withAnimation(fromChange ? .easeInOut(duration: 0.6) : .easeInOut(duration: 1)) {
                filteredRegisters[index].animate = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        
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
        
        @State var currentTab: String = "Semana"
        
        BarChartView_Cual(testRegisters: testRegisters, currentTab: $currentTab)
    }
}


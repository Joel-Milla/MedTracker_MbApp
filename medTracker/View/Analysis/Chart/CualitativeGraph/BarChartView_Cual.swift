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
    let symptomRegisters: [Register]
    // MARK: View Properties
    @Binding var currentTab: String
    @State var filteredRegisters: [Register] = []
    // MARK: Gesture Properties
    @State var currentActiveItem: Register?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        // MARK: Bar Chart API that changes when the currentTab (time zone selected changes)
        AnimatedCharts()
            .onChange(of: currentTab) { newValue in
                filteredRegisters = symptomRegisters.filterBy(currentTab)
                // Re-Animating View
                animateGraph(fromChange: true)
            }
    }
    
    @ViewBuilder
    func AnimatedCharts() -> some View {
        // Values to block the x scale from moving
        let minDate = filteredRegisters.adjustDatesToStartOfDay().map { $0.date }.min() ?? Date()
        let maxDate = filteredRegisters.adjustDatesToStartOfDay().map { $0.date }.max() ?? Date()
        
        Chart {
            ForEach(filteredRegisters) { register in
                // MARK: Bar Graph
                BarMark(
                    x: .value("Fecha", register.adjustDateToDay().date, unit: .day),
                    y: .value("Cantidad", register.animate ? register.amount : 0)
                )
                // Applying Gradient Style
                // From swiftui 4.0 can direclty create gradient color
                .foregroundStyle(.blue.gradient)
                
                // MARK: Rule Mark for currently dragging item
                // The current item is choosen when the user makes a drag motion.
                if let currentActiveItem, currentActiveItem.id.uuidString == register.id.uuidString {
                    // Add a rule on the x value on the graph
                    RuleMark(x: .value("Fecha", currentActiveItem.adjustDateToDay().date))
                    // MARK: Use offset to show the rule line in the middle of the current selected bar lines
                        .offset(x: (plotWidth / CGFloat(filteredRegisters.count)) / 2)
                    // Add an annotation on top of the vertical line to show the value of the nearest item
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                // Show the date of the current value and the value
                                Text(currentActiveItem.date.dateToStringMDH())
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                // Obtain the image of the current value
                                let imageName = HelperFunctions.getImage(of: currentActiveItem.amount)
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
                            // Move the annotation when it is on the corners so the annotation shows clearly and not on borders
                            .offset(x: currentActiveItem.date.dateToStringMDH() == minDate.dateToStringMDH() ? 35 : currentActiveItem.date.dateToStringMDH() == maxDate.dateToStringMDH() ? -20 : 0)
                        }
                }
            }
        }
        // MARK: Customizing x and y axis length
        // Customizing the x labels depending on the time zone selected
        // hard code the scale so it has an extra day and to make the bar chart to not be out of bounds.
        .chartXScale(domain: minDate...maxDate.addingTimeInterval(86400))
        // MARK: Customizing x and y axis length
        .chartYScale(domain: [0, 150]) // bigger number, smaller the bar charts
        // MARK: Customizing the y labels
        .chartYAxis {
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
                                        self.currentActiveItem = closestRegister // set the closes register globally to put marks on there
                                        self.plotWidth = proxy.plotAreaSize.width // Obtain the width of the plot to know where to put the marks on the x axis
                                        
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
            // Filter the current regiser based on the current time zone.
            filteredRegisters = symptomRegisters.filterBy(currentTab)
            animateGraph()
        }
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

#Preview {
    NavigationStack {
        
        let symptomRegisters: [Register] = RegisterList.getDefaultRegisters()
        
        @State var currentTab: String = "Semana"
        
        BarChartView_Cual(symptomRegisters: symptomRegisters, currentTab: $currentTab)
    }
}


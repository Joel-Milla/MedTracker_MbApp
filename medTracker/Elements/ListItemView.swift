//
//  ListItemView.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 04/04/24.
//

import Foundation
import SwiftUI
import Charts

struct ListItemView: View {
    let item: Symptom
    let registers : [Register]
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20).foregroundStyle(Color(hex: item.color))
                    Text(item.nombre)
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 10)
                }
                .padding(.vertical)
                HStack{
                    Text("\(item.fecha.formatted(date: .abbreviated, time: .omitted))  |  64kg")
                        .font(.subheadline)
                }
                Spacer()
            }
            Spacer()
            VStack{
                ChartCuantitativa(filteredRegisters: registers)
            }
        }
    }
    @ViewBuilder
    func ChartCuantitativa(filteredRegisters: [Register]) -> some View {
        
        let registers = filteredRegisters.sorted { $0.fecha < $1.fecha }
        
        let spm = operaciones(registers: registers)
        
        let min = spm[2]*0.8
        let max = spm[1]*1.2
        
        Chart {
            ForEach(registers, id:\.self) { register in
                BarMark (
                    x: .value("Día", register.fecha, unit: .day),
                    y: .value("CANTIDAD", register.cantidad)//register.animacion ? register.cantidad : 0)
                )
                .foregroundStyle(Color(hex: item.color))
                .interpolationMethod(.catmullRom)
                
                AreaMark (
                    x: .value("Día", register.fecha, unit: .day),
                    yStart: .value("minY", min),
                    yEnd: .value("maxY", register.cantidad)
                )
                .foregroundStyle(Color(hex: item.color).opacity(0.1))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        //.chartYScale(domain: min)
        .frame(width: 70, height: 50)
        //.background(Color("mainWhite"))
        
    }
    func operaciones(registers: [Register]) -> [Float] {
        var operacionesList : [Float] = [0,0,Float.greatestFiniteMagnitude]
        
        for item in registers {
            operacionesList[0] = operacionesList[0] + item.cantidad
            if operacionesList[1] < item.cantidad {
                operacionesList[1] = item.cantidad
            }
            if operacionesList[2] > item.cantidad {
                operacionesList[2] = item.cantidad
            }
        }
        operacionesList[0] = operacionesList[0] / Float(registers.count)
        
        return operacionesList
    }
}

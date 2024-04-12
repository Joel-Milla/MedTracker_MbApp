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
    @ObservedObject var registers : RegisterList
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20).foregroundStyle(Color(hex: item.color))
                    Text(item.name)
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 10)
                }
                .padding(.vertical)
                HStack{
                    Text("\(item.creationDate.formatted(date: .abbreviated, time: .omitted))  |  64kg")
                        .font(.subheadline)
                }
                Spacer()
            }
            Spacer()
            VStack{
                if last7DaysRegisterList().registers[item.id.uuidString]?.count ?? 0 > 2 {
                    ChartCuantitativa(filteredRegisters: last7DaysRegisterList())
                }
            }
        }
    }
    
    @MainActor private func last7DaysRegisterList() -> RegisterList {
        let last7DaysRegisters = last7DaysRegisters()
        var registerList = RegisterList(repository: registers.repository)
        registerList.registers = registers.registers // Copia el diccionario original
        registerList.registers[item.id.uuidString] = last7DaysRegisters // Reemplaza los registros de este síntoma con los últimos 7 días
        return registerList
    }
    
    @MainActor private func last7DaysRegisters() -> [Register] {
        let calendar = Calendar.current
        // Obtenemos la fecha actual sin la hora exacta
        let today = Date()
        // Calculamos la fecha de hace 7 días atrás
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return []
        }
        // Filtramos los registros para obtener solo los de los últimos 7 días
        let last7DaysRegisters = registers.filterBy(item).filter { $0.date >= sevenDaysAgo && $0.date <= today }
        return last7DaysRegisters
    }

    
    @MainActor @ViewBuilder
    func ChartCuantitativa(filteredRegisters: RegisterList) -> some View {
        
        
        let jointRegisters = filteredRegisters.registers[item.id.uuidString] ?? []
        
        let registers = jointRegisters.sorted { $0.date < $1.date }
        
        let spm = operaciones(registers: registers)
        
        let min = spm[2]*0.8
//        let max = spm[1]*1.2 // Variable never used
        
        Chart {
            ForEach(registers, id:\.self) { register in
                BarMark (
                    x: .value("Día", register.date, unit: .day),
                    y: .value("CANTIDAD", register.amount)//register.animacion ? register.cantidad : 0)
                )
                .foregroundStyle(Color(hex: item.color))
                .interpolationMethod(.catmullRom)
                
//                AreaMark (
//                    x: .value("Día", register.date, unit: .day),
//                    yStart: .value("minY", min),
//                    yEnd: .value("maxY", register.amount)
//                )
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
            operacionesList[0] = operacionesList[0] + item.amount
            if operacionesList[1] < item.amount {
                operacionesList[1] = item.amount
            }
            if operacionesList[2] > item.amount {
                operacionesList[2] = item.amount
            }
        }
        operacionesList[0] = operacionesList[0] / Float(registers.count)
        
        return operacionesList
    }
}

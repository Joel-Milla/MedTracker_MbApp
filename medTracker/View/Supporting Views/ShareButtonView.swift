//
//  ShareButtonView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 10/04/24.
//

import SwiftUI

struct ShareButtonView: View {
    let symptomList: SymptomList
    let registerList: RegisterList
    
    var body: some View {
        ShareLink("", item: generateCSV())
    }
    
    @MainActor func generateCSV() -> URL {
        var fileURL: URL!
        // heading of CSV file.
        let heading = "Síntoma, Día, Cantidad\n"
        var rows: [String] = []
        
        // Obtain an array of strings containing the data of each row
        for (idSymptom, registers) in registerList.registers {
            let symptomName = symptomList.symptoms[idSymptom]?.name ?? "Sin definir"
            for register in registers {
                rows.append("\(symptomName),\(register.date.dateToStringMDH()),\(register.amount)")
            }
        }
        
        
        // Join all the data into a single string
        let stringData = heading + rows.joined(separator: "\n")
        
        do {
            // Create a path in the file manager
            let path = try FileManager.default.url(for: .documentDirectory,
                                                   in: .allDomainsMask,
                                                   appropriateFor: nil,
                                                   create: false)
            // Give a name to the file
            fileURL = path.appendingPathComponent("Registros.csv")
            
            // Write in the fileManager (in that direction) the string data
            try stringData.write(to: fileURL, atomically: true , encoding: .utf8)
            
        } catch {
            customPrint("[ShareButtonView] Error generating csv file")
        }
        return fileURL
    }
}

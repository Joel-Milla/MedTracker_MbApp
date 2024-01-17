//
//  RegisterList.swift
//  medTracker
//
//  Created by Alumno on 10/11/23.
//

import Foundation

/**********************
 This class contains all the data that the user registered about their symptoms.
 **********************************/
@MainActor
class RegisterList : ObservableObject {
    @Published var registers = [Register]() {
        didSet {
            HelperFunctions.write(self.registers, inPath: registersURL)
        }
    }
    let repository: Repository
    private var registersURL: URL {
        do {
            let documentsDirectory = try HelperFunctions.filePath("registers")
            return documentsDirectory
        }
        catch {
            fatalError("[RegisterList] An error occurred while getting the url of registers list: \(error)")
        }
    }
    
    /**********************
     Important initialization method
     **********************************/
    init(repository: Repository) {
        self.repository = repository
        if let decodedData = HelperFunctions.loadData(in: registersURL, as: [Register].self) {
            self.registers = decodedData
        }
        
        //If no JSON, fetch info
        fetchRegisters()
        
        // For testing, the next function can be used for dummy data.
        //registers = getDefaultRegisters()
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // The functions returns a closure that is used to write information in firebase
    func makeCreateAction() -> RegisterSymptomView.CreateAction {
        return { [weak self] register in
            try await self?.repository.createRegister(register)
        }
    }
    
    // Fetch registers data from the database and save them on the registers list.
    func fetchRegisters() {
        Task {
            do {
                registers = try await self.repository.fetchRegisters()
            } catch {
                print("[RegisterList] Cannot fetch registers: \(error)")
            }
        }
    }
    
    // Delete registers that have a certain symptom
    func deleteRegister(indexSymptom: String) {
        for register in registers {
            if register.idSymptom == indexSymptom {
                Task {
                    try await self.repository.deleteRegister(register)
                }
            }
        }
        registers.removeAll {
            $0.idSymptom == indexSymptom
        }
    }
    
    // Dummy data for testing purposes.
    private func getDefaultRegisters() -> [Register] {
        return [
            Register(idSymptom: "as", fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            Register(idSymptom: "as", fecha: Date.now.addingTimeInterval(86400), cantidad: 80.5, notas: "Esto es una nota."),
            Register(idSymptom: "as", fecha: Date.now.addingTimeInterval(86400*2), cantidad: 80.2, notas: "Esto es una nota."),
            Register(idSymptom: "as", fecha: Date.now.addingTimeInterval(86400*3), cantidad: 20, notas: "Esto es una nota."),
            
            Register(idSymptom: "asg", fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            
            Register(idSymptom: "asf", fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            Register(idSymptom: "asf", fecha: Date.now.addingTimeInterval(86400), cantidad: 70, notas: "Esto es una nota."),
            Register(idSymptom: "asf", fecha: Date.now.addingTimeInterval(86400*2), cantidad: 30, notas: "Esto es una nota."),
            Register(idSymptom: "asf", fecha: Date.now.addingTimeInterval(86400*3), cantidad: 40, notas: "Esto es una nota."),
            
            Register(idSymptom: "asfsd", fecha: Date.now, cantidad: 80, notas: "Esto es una nota.")
        ]
    }
}

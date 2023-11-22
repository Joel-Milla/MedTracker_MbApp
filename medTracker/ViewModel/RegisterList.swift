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

class RegisterList : ObservableObject {
    @Published var registers = [Register]() {
        didSet {
            HelperFunctions.write(self.registers, inPath: "Registers.JSON")
        }
    }
    let repository = Repository()
    
    /**********************
     Important initialization method
     **********************************/
    init() {
        if let datosRecuperados = try? Data.init(contentsOf: HelperFunctions.filePath("Registers.JSON")) {
            if let datosDecodificados = try? JSONDecoder().decode([Register].self, from: datosRecuperados) {
                registers = datosDecodificados
                return
            }
        }
        
        //If no JSON, fetch info
        fetchRegisters()
        
        // For testing, the next function can be used for dummy data.
        registers = getDefaultRegisters()
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
                print("[PostsViewModel] Cannot fetch posts: \(error)")
            }
        }
    }
    
    // Dummy data for testing purposes.
    private func getDefaultRegisters() -> [Register] {
        return [
            Register(idSymptom: 1, fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            Register(idSymptom: 1, fecha: Date.now.addingTimeInterval(86400), cantidad: 80.5, notas: "Esto es una nota."),
            Register(idSymptom: 1, fecha: Date.now.addingTimeInterval(86400*2), cantidad: 80.2, notas: "Esto es una nota."),
            Register(idSymptom: 1, fecha: Date.now.addingTimeInterval(86400*3), cantidad: 20, notas: "Esto es una nota."),
            
            Register(idSymptom: 2, fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            
            Register(idSymptom: 3, fecha: Date.now, cantidad: 80, notas: "Esto es una nota."),
            Register(idSymptom: 3, fecha: Date.now.addingTimeInterval(86400), cantidad: 70, notas: "Esto es una nota."),
            Register(idSymptom: 3, fecha: Date.now.addingTimeInterval(86400*2), cantidad: 30, notas: "Esto es una nota."),
            Register(idSymptom: 3, fecha: Date.now.addingTimeInterval(86400*3), cantidad: 40, notas: "Esto es una nota."),
            
            Register(idSymptom: 4, fecha: Date.now, cantidad: 80, notas: "Esto es una nota.")
        ]
    }
}

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
    typealias Action = () async throws -> Void

    @Published var registers = [String: [Register]]() {
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
        if let decodedData = HelperFunctions.loadData(in: registersURL, as: [String: [Register]].self) {
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
    // Filter the registers by a symptom
    func filterBy(_ symptom: Symptom) -> [Register] {
        return registers[symptom.id.uuidString] ?? []
    }
    
    // Return a formViewModel that handles the creation of a new register
    func createRegisterViewModel(idSymptom: String) -> FormViewModel<Register> {
        return FormViewModel(initialValue: Register(idSymptom: idSymptom)) { [weak self] register in
            let (hasError, message) = register.validateInput()
            // if the symptom doesnt have valid input, throw an error
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else {
                // If the symptom doesnt have a register yet, create it
                if self?.registers[idSymptom] == nil {
                    self?.registers[idSymptom] = []
                }
                // Insert the new register
                if var registersOfSymptom = self?.registers[idSymptom] {
                    // Index to insert the register in a sorted way
                    let insertIndex = registersOfSymptom.firstIndex(where: {$0.fecha > register.fecha}) ?? registersOfSymptom.endIndex
                    registersOfSymptom.insert(register, at: insertIndex)
                    self?.registers[idSymptom] = registersOfSymptom
                    
                    // Make the request to firebase to create the register
                    do {
                        try await self?.repository.createRegister(register)
                    } catch {
                        try HelperFunctions.handleFirestoreError(code: error)
                    }
                }
            }
        }
    }
    
    
    // ************* DELETE WHEN makeCreateAction in RegisterSymptomView IS NOT USED *************
    // ******************************************************************
    // ******************************************************************
    // The functions returns a closure that is used to write information in firebase
//    func makeCreateAction() -> RegisterSymptomView.CreateAction {
//        return { [weak self] register in
//            try await self?.repository.createRegister(register)
//        }
//    }
    // ************* DELETE WHEN makeCreateAction in RegisterSymptomView IS NOT USED *************
    // ******************************************************************
    // ******************************************************************
    
    // The functions returns a closure that is used to delete all registers of a symptom.
//    func makeDeleteAction(for symptom: Symptom) -> Action {
//        return { [weak self] in
//            self?.registers.removeAll{ $0.id == symptom.id}
//            if let registers = self?.registers {
//                for local_register in registers {
//                    if local_register.idSymptom == symptom.id.uuidString {
//                        try await self?.repository.deleteRegister(local_register)
//                    }
//                }
//            }
//        }
//    }


    // Fetch registers data from the database and save them on the registers list.
    func fetchRegisters() {
        Task {
            do {
                registers = try await self.repository.fetchRegisters()
            } catch {
                customPrint("[RegisterList] Cannot fetch registers: \(error)")
            }
        }
    }
    
    // Delete registers that have a certain symptom
//    func deleteRegistersSymptom(indexSymptom: String) {
//        for register in registers {
//            if register.idSymptom == indexSymptom {
//                Task {
//                    try await self.repository.deleteRegister(register)
//                }
//            }
//        }
//        registers.removeAll {
//            $0.idSymptom == indexSymptom
//        }
//    }
    
    // Delete specific registers
//    func deleteRegisterSet(atOffset indexSet: IndexSet, ofSymptom symptom: Symptom) {
//        let filteredRegisters = registers.filter({ $0.idSymptom == symptom.id.uuidString }).sorted(by: {$0.fecha > $1.fecha})
//        let idsToDelete = indexSet.map { filteredRegisters[$0].id }
//        
//        registers.removeAll { register in
//            idsToDelete.contains(register.id)
//        }
//        
//        idsToDelete.forEach { id in
//            Task {
//                try await self.repository.deleteRegisterByID(id)
//            }
//        }
//        
//    }
    
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

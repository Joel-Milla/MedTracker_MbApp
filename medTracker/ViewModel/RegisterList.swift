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
        } else {
            //If no JSON, fetch info
            fetchRegisters()
        }
        
        
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
                    let insertIndex = registersOfSymptom.firstIndex(where: {$0.date > register.date}) ?? registersOfSymptom.endIndex
                    registersOfSymptom.insert(register, at: insertIndex)
                    
                    // MARK: Check if there is already a register on the same day
                    let calendar = Calendar.current
                    let previousIndex = insertIndex - 1
                    let nextIndex = insertIndex + 1
                    let newRegisterDate = calendar.startOfDay(for: register.date)
                    // Check previous date if it exists
                    if previousIndex >= 0 && previousIndex < registersOfSymptom.count {
                        let previousDate = calendar.startOfDay(for: registersOfSymptom[previousIndex].date)
                        if newRegisterDate == previousDate {
                            throw HelperFunctions.ErrorType.invalidInput("Ya existe un registro en esta fecha.")
                        }
                    }
                    
                    // Check next date if it exists
                    if nextIndex < registersOfSymptom.count {
                        let nextDate = calendar.startOfDay(for: registersOfSymptom[nextIndex].date)
                        if newRegisterDate == nextDate {
                            throw HelperFunctions.ErrorType.invalidInput("Ya existe un registro en esta fecha.")
                        }
                    }
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
    static func getDefaultRegisters() -> [Register] {
        return [
            Register(idSymptom: "SYM-571"),
            Register(idSymptom: "SYM-603", date: Date().addingTimeInterval(-32400), amount: 8.92, notes: "Note 40"),
            Register(idSymptom: "SYM-603", date: Date().addingTimeInterval(-86400 * 1), amount: 8.92, notes: "Note 40"),
            Register(idSymptom: "SYM-358", date: Date().addingTimeInterval(-86400 * 2), amount: 1.36, notes: "Note 25"),
            Register(idSymptom: "SYM-797", date: Date().addingTimeInterval(-86400 * 3), amount: 7.07, notes: "Note 68"),
            Register(idSymptom: "SYM-936", date: Date().addingTimeInterval(-86400 * 4), amount: 9.86, notes: "Note 33"),
            Register(idSymptom: "SYM-781", date: Date().addingTimeInterval(-86400 * 5), amount: 3.29, notes: "Note 77"),
            Register(idSymptom: "SYM-272", date: Date().addingTimeInterval(-86400 * 6), amount: 9.24, notes: "Note 10"),
            Register(idSymptom: "SYM-158", date: Date().addingTimeInterval(-86400 * 7), amount: 5.29, notes: "Note 90"),
            Register(idSymptom: "SYM-739", date: Date().addingTimeInterval(-86400 * 8), amount: 2.67, notes: "Note 46"),
            Register(idSymptom: "SYM-342", date: Date().addingTimeInterval(-86400 * 9), amount: 5.2, notes: "Note 21"),
            Register(idSymptom: "SYM-343", date: Date().addingTimeInterval(-86400 * 10), amount: 5.2, notes: "Note 22"),
            Register(idSymptom: "SYM-344", date: Date().addingTimeInterval(-86400 * 11), amount: 5.2, notes: "Note 23"),
            Register(idSymptom: "SYM-345", date: Date().addingTimeInterval(-86400 * 12), amount: 22, notes: "Note 24"),
            Register(idSymptom: "SYM-346", date: Date().addingTimeInterval(-86400 * 13), amount: 5.2, notes: "Note 25"),
            Register(idSymptom: "SYM-347", date: Date().addingTimeInterval(-86400 * 14), amount: 9, notes: "Note 29"),
            Register(idSymptom: "SYM-347", date: Date().addingTimeInterval(-86400 * 56), amount: 3.4, notes: "Note 30")
        ]
    }
}

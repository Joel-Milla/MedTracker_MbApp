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

    // The registers contained are in ascending order, from the oldest to the newest register. Are sorted by date
    // The key is the idSymptom and each value are all the registers of that symptom
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
        
        setBloodPressureRegisters()
        
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
    
    // Return a formViewModel that handles the register of blood pressure
    func createBPRegisterViewModel() -> FormViewModel<(date: Date, systolicValue: Float, diastolicValue: Float, notes: String)> {
        return FormViewModel(initialValue: (Date.now, -1000.99, -1000.99, "")) { [weak self] (date, systolic, diastolic, notes) in
            var (hasError, message): (Bool, String) = (false, "")
            // check if there is any error with the data
            if (systolic == -1000.99 || diastolic == -1000.99) {
                hasError = true
                message = "Por favor de ingresar un dato valido."
            }
            if (systolic <= diastolic) {
                hasError = true
                message = "Por favor de ingresar datos validos."
            }
            // if the symptom doesnt have valid input, throw an error
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else {
                // Insert the new register
                if var systolicRegisters = self?.registers[HelperFunctions.zeroOneOneUUID.uuidString],
                   var diastolicRegisters = self?.registers[HelperFunctions.zeroOneUUID.uuidString]
                {
                    // Create the register for systolic and diastolic
                    let systolicRegister = Register(idSymptom: HelperFunctions.zeroOneOneUUID.uuidString, date: date, amount: systolic, notes: notes)
                    let diastolicRegister = Register(idSymptom: HelperFunctions.zeroOneUUID.uuidString, date: date, amount: diastolic, notes: notes)
                    // Index to insert the register in a sorted way
                    let insertIndex = systolicRegisters.firstIndex(where: {$0.date > date}) ?? systolicRegisters.endIndex
                    systolicRegisters.insert(systolicRegister, at: insertIndex)
                    diastolicRegisters.insert(diastolicRegister, at: insertIndex)
                    
                    // MARK: Check if there is already a register on the same day
                    let calendar = Calendar.current
                    let previousIndex = insertIndex - 1
                    let nextIndex = insertIndex + 1
                    let newRegisterDate = calendar.startOfDay(for: date)
                    // Check previous date if it exists
                    if previousIndex >= 0 && previousIndex < systolicRegisters.count {
                        let previousDate = calendar.startOfDay(for: systolicRegisters[previousIndex].date)
                        if newRegisterDate == previousDate {
                            throw HelperFunctions.ErrorType.invalidInput("Ya existe un registro en esta fecha.")
                        }
                    }
                    
                    // Check next date if it exists
                    if nextIndex < systolicRegisters.count {
                        let nextDate = calendar.startOfDay(for: systolicRegisters[nextIndex].date)
                        if newRegisterDate == nextDate {
                            throw HelperFunctions.ErrorType.invalidInput("Ya existe un registro en esta fecha.")
                        }
                    }
                    // Create both registers
                    self?.registers[HelperFunctions.zeroOneOneUUID.uuidString] = systolicRegisters
                    self?.registers[HelperFunctions.zeroOneUUID.uuidString] = diastolicRegisters
                    
                    // Make the request to firebase to create the registers
                    do {
                        try await self?.repository.createRegister(systolicRegister)
                        try await self?.repository.createRegister(diastolicRegister)
                    } catch {
                        try HelperFunctions.handleFirestoreError(code: error)
                    }
                }
            }
        }
    }
    
    // Create viewModel that manages the deletion of registers in registersView
         func createEditRegistersViewModel(for symptom: Symptom) -> EditRegisterViewModel {
             let symptomId = symptom.id.uuidString
             // Registers to show
             let filteredRegisters = self.registers[symptomId] ?? []
             // Closure to delete registers from the main array of registers
             let deleteAction = { [weak self] (indicesToRemove: IndexSet) in
                 // Iterater the filtered register and remove those indices
                 for index in indicesToRemove {
                     try await self?.repository.deleteRegister(filteredRegisters[index])
                 }
                 // Remove the registers from firebase
                 self?.registers[symptomId]?.remove(atOffsets: indicesToRemove)
             }

             return EditRegisterViewModel(symptom: symptom, registers: filteredRegisters, deleteRegistersAction: deleteAction)
         }
    
    // Function to delete all the registers from the dictionary and from firebase
    func deleteRegisters(at indices: IndexSet, from filteredSymptoms: [Symptom]) {
        for index in indices {
            let symptom = filteredSymptoms[index]
            let registersToDelete: [Register]
            // Check if symptom to delete is normal symptom or blood pressure
            if (symptom.id == HelperFunctions.zeroUUID) {
                let systolicRegisters = registers[HelperFunctions.zeroOneOneUUID.uuidString] ?? []
                let diastolicRegisters = registers[HelperFunctions.zeroOneUUID.uuidString] ?? []
                registersToDelete = systolicRegisters + diastolicRegisters
                registers.removeValue(forKey: HelperFunctions.zeroOneOneUUID.uuidString)
                registers.removeValue(forKey: HelperFunctions.zeroOneUUID.uuidString)
            } else {
                registersToDelete = registers[symptom.id.uuidString] ?? []
                registers.removeValue(forKey: symptom.id.uuidString) // Remove the values of a single symptom
            }
            // Delete the symptom in the repository. Use task to avoid making this function async
            Task {
                // Delete all the registers from firestore
                for register in registersToDelete {
                    try await repository.deleteRegister(register)
                }
            }
        }
    }

    // Fetch registers data from the database and save them on the registers list.
    func fetchRegisters() {
        Task {
            do {
                registers = try await self.repository.fetchRegisters()
                setBloodPressureRegisters()
            } catch {
                customPrint("[RegisterList] Cannot fetch registers: \(error)")
            }
        }
    }
    
    // Create registers for blood pressure registers if they dont exist
    private func setBloodPressureRegisters() {
        if registers[HelperFunctions.zeroOneOneUUID.uuidString] == nil || registers[HelperFunctions.zeroOneUUID.uuidString] == nil {
            // Test data
//            let systolicTestData = [
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 9), amount: 115.6, notes: "Good sleep"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 8), amount: 123.5, notes: "Slightly stressed"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 7), amount: 117.8, notes: "Very relaxed"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 6), amount: 121.0, notes: "Workout day"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 5), amount: 119.9, notes: "Mild headache"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 4), amount: 116.4, notes: "Normal day"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 3), amount: 125.1, notes: "High salt meal"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 2), amount: 118.7, notes: "Regular exercise"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 1), amount: 122.3, notes: "Restful sleep"),
//                Register(idSymptom: "SYM-SYS", date: Date().addingTimeInterval(-86400 * 0), amount: 120.5, notes: "Stressful day")
//            ]
//
//            // Array for Diastolic Blood Pressure (lower values typically ranging from 70 to 90 mmHg)
//            let diastolicTestData = [
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 9), amount: 73.4, notes: "Quiet day at home"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 8), amount: 81.6, notes: "Stressful meeting"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 7), amount: 75.8, notes: "Movie night"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 6), amount: 79.0, notes: "Jogging"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 5), amount: 77.2, notes: "Visited friends"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 4), amount: 74.9, notes: "Regular workday"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 3), amount: 82.1, notes: "Ate out"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 2), amount: 76.4, notes: "Early morning walk"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 1), amount: 78.6, notes: "Late night work"),
//                Register(idSymptom: "SYM-DIA", date: Date().addingTimeInterval(-86400 * 0), amount: 80.3, notes: "Calm evening")
//            ]
            
            // If it doesn't exist, create and add it
            registers[HelperFunctions.zeroOneOneUUID.uuidString] = []
            registers[HelperFunctions.zeroOneUUID.uuidString] = []
        }
    }
    
    // Dummy data for testing purposes.
    static func getDefaultRegisters() -> [Register] {
        return [
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

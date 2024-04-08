//
//  SymptomList.swift
//  medTracker
//
//  Created by Alumno on 10/11/23.
//

import Foundation
import SwiftUI

/**********************
 This class contains all the symptoms of the user.
 **********************************/
@MainActor
class SymptomList : ObservableObject {
    typealias Action = () async throws -> Void

    @Published var symptoms = [String: Symptom]() {
        didSet {
            updateStateBasedOnSymptoms()
            HelperFunctions.write(self.symptoms, inPath: symptomListURL)
        }
    }
    @Published var state: State = .isLoading //State of the symptoms array
    let repository: Repository // Variable to call the functions inside the repository
    // URL where the files will be created.
    private var symptomListURL: URL {
        do {
            let documentsDirectory = try HelperFunctions.filePath("symptoms")
            return documentsDirectory
        }
        catch {
            fatalError("[SymptomList] An error occurred while getting the url of symptoms list: \(error)")
        }
    }

    /**********************
     Important initialization methods
     **********************************/
    init(repository: Repository) {
        self.repository = repository
        if let decodedData = HelperFunctions.loadData(in: symptomListURL, as: [String: Symptom].self) {
            self.symptoms = decodedData
        }
        //If there is no info in JSON, fetch
        fetchSymptoms()
        
        // For testing, the next function can be used for dummy data.
        //symptoms = getDefaultSymptoms()
    }
    
    enum State {
        case complete
        case isLoading
        case isEmpty
    }
    
    /**********************
     Helper functions
     **********************************/
    
    // Functions used in CreateSymptomView that is the new view.
    // ******************************************************************
    // ******************************************************************
    
    // Return a formViewModel that handles the creation of a new symptom
    func createSymptomViewModel() -> FormViewModel<Symptom> {
        return FormViewModel(initialValue: Symptom()) { [weak self] symptom in
            let (hasError, message) = symptom.validateInput()
            let symptomExists = self?.symptoms.values.contains(where: { $0.nombre == symptom.nombre }) ?? false // Validate if a symptom with the same name already exists
            // if the symptom doesnt have valid input, throw an error
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else if (symptomExists) {
                throw HelperFunctions.ErrorType.general("Un dato con ese sintoma ya se esta registrando")
            }
            else {
                // Schedule notifications based on the input received from the user
                NotificationManager.instance.scheduleNotifications(symptom.notificacion, symptom.nombre)
                self?.symptoms[symptom.id.uuidString] = symptom
                try await self?.repository.createSymptom(symptom) // use function in the repository to create the symptom
            }
        }
    }
    
    
    // Functions used in CreateSymptomView that is the new view.
    // ******************************************************************
    // ******************************************************************
    
    
    
    
    
    // ************* DELETE WHEN AddSymptomView IS NOT USED *************
    // ******************************************************************
    // ******************************************************************
    
    // The functions returns a closure that is used to write information in firebase
//    func makeCreateAction() -> AddSymptomView.CreateAction {
//        return { [weak self] symptom in
//            try await self?.repository.createSymptom(symptom)
//        }
//    }
    // ******************************************************************
    // ******************************************************************
    // ************* DELETE WHEN AddSymptomView IS NOT USED *************
    
    // The functions returns a closure that is used to write information in firebase
//    func makeUpdateAction(for symptom: Symptom) -> Action {
//        return { [weak self] in
//            let index = self?.symptoms.firstIndex(of: symptom)
//            if let index = index {
//                self?.symptoms[index].activo.toggle()
//            }
//            try await self?.repository.updateSymptomActivo(symptom)
//        }
//    }
    
    // The functions returns a closure that is used to write information in firebase
//    func makeDeleteAction(for symptom: Symptom) -> Action {
//        return { [weak self] in
//            self?.symptoms.removeAll{ $0.id == symptom.id}
//            try await self?.repository.deleteSymptom(symptom)
//        }
//    }
    
    // Fetch symptoms from the database and save them on the symptoms list.
    func fetchSymptoms() {
        state = .isLoading
        Task {
            do {
                symptoms = try await self.repository.fetchSymptoms()
                state = symptoms.isEmpty ? .isEmpty : .complete
            } catch {
                customPrint("[SymptomList] Cannot fetch symptoms: \(error)")
            }
        }
    }
    
    // Function to delete a symptom
//    func deleteSymptom(symptom : Symptom) {
//        self.symptoms.removeAll{ $0.id == symptom.id }
//        Task {
//            do {
//                try await self.repository.deleteSymptom(symptom)
//            } catch {
//                customPrint("[SymptomList] Cannot delete symptom: \(error)")
//            }
//        }
//    }
    
    // Function to update the state of the syntomsList. This is called each time the list is modified.
    private func updateStateBasedOnSymptoms() {
        if symptoms.isEmpty {
            state = .isEmpty
        } else {
            state = .complete
        }
    }
    
    func returnName(id : String) -> String {
        let name = self.symptoms[id]?.nombre ?? ""
        return name
    }
    
    func returnActive(id : String) -> Bool {
        let activo = self.symptoms[id]?.activo ?? false
        return activo
    }
    
    // Dummy data for testing purposes.
    private func getDefaultSymptoms() -> [Symptom] {
        return [
            Symptom(nombre: "Peso", icon: "star.fill",  description: "Este es un ejemplo de descripción que es bastante largo y se va haciendo mucho más largo para comprobar la funcionalidad.", cuantitativo: true, unidades: "kg", activo: true, color: "#007AF", notificacion: ""),
            Symptom(nombre: "Cansancio", icon: "star.fill", description: "Este es un ejemplo de descripción corto.", cuantitativo: false, unidades: "", activo: true, color: "#AF43EB", notificacion: "sssss"),
            Symptom(nombre: "Insomnio", icon: "star.fill", description: "Este es un ejemplo de descripción mediano, es decir, con esto está bien.", cuantitativo: true, unidades: "", activo: true, color: "#D03A20", notificacion: ""),
            Symptom(nombre: "Estado cardíaco", icon: "star.fill", description: "Latidos por minuto.", cuantitativo: true, unidades: "BPM", activo: true, color: "#86B953", notificacion: ""),
            Symptom(nombre: "Estado cardíaco 2", icon: "star.fill", description: "Latidos por minuto.", cuantitativo: true, unidades: "BPM", activo: true, color: "#86B953", notificacion: "ssssss")
            
        ]
    }
}

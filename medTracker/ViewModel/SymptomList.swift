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
    @Published var symptoms = [Symptom]() {
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
        if let decodedData = HelperFunctions.loadData(in: symptomListURL, as: [Symptom].self) {
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
    
    // The functions returns a closure that is used to write information in firebase
    func makeCreateAction() -> AddSymptomView.CreateAction {
        return { [weak self] symptom in
            try await self?.repository.createSymptom(symptom)
        }
    }
    
    // Fetch symptoms from the database and save them on the symptoms list.
    func fetchSymptoms() {
        state = .isLoading
        Task {
            do {
                symptoms = try await self.repository.fetchSymptoms()
                state = symptoms.isEmpty ? .isEmpty : .complete
            } catch {
                print("[SymptomList] Cannot fetch symptoms: \(error)")
            }
        }
    }
    
    // Function to delete a symptom
    func deleteSymptom(symptom : Symptom) {
        self.symptoms.removeAll{ $0.id == symptom.id }
        Task {
            do {
                try await self.repository.deleteSymptom(symptom)
            } catch {
                print("[SymptomList] Cannot delete symptom: \(error)")
            }
        }
    }
    
    // Function to update the state of the syntomsList. This is called each time the list is modified.
    private func updateStateBasedOnSymptoms() {
        if symptoms.isEmpty {
            state = .isEmpty
        } else {
            state = .complete
        }
    }
    func returnName(id : String)->String{
        var name = ""
        for symptom in self.symptoms{
            if symptom.id.uuidString == id{
                name = symptom.nombre
            }
        }
        return name
    }
    func returnActive(id : String) -> Bool{
        for symptom in self.symptoms {
            if symptom.id.uuidString == id{
                return symptom.activo
            }
        }
        return false
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

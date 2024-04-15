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

    // The key is the idSymptom and then the structure symptom is the value
    @Published var symptoms = [String: Symptom]() {
        didSet {
            updateStateBasedOnSymptoms()
            HelperFunctions.write(self.symptoms, inPath: symptomListURL)
        }
    }
    // This computed property returns an array of symptoms ordered by date. The first element of the array is the newest
    // Also consdiers if the symptoms are active or not
    var sortedSymptoms: [Symptom] {
        // First, sort by isActive status (true first), then by creationDate within each group
        symptoms.values.sorted {
            if $0.isFavorite == $1.isFavorite {
                return $0.creationDate > $1.creationDate // Sort by date within the same isActive group
            }
            return $0.isFavorite && !$1.isFavorite // Prioritize active symptoms
        }
    }
    
    @Published var state: State = .isLoading //State of the symptoms array to update views depending on what is happening here
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
        } else {
            //If there is no info in JSON, fetch
            fetchSymptoms()
        }
        
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
    
    // Return a formViewModel that handles the creation of a new symptom in CreateSymptomView
    func createSymptomViewModel() -> FormViewModel<Symptom> {
        return FormViewModel(initialValue: Symptom()) { [weak self] symptom in
            let (hasError, message) = symptom.validateInput()
            let symptomExists = self?.symptoms.values.contains(where: { $0.name == symptom.name }) ?? false // Validate if a symptom with the same name already exists
            // if the symptom doesnt have valid input, throw an error
            if (hasError) {
                throw HelperFunctions.ErrorType.invalidInput(message)
            } else if (symptomExists) {
                throw HelperFunctions.ErrorType.general("Un dato con ese sintoma ya se esta registrando")
            }
            else {
                // Schedule notifications based on the input received from the user. When notification is empty, this function doesn't do anything
                NotificationManager.instance.scheduleNotifications(symptom.notification, symptom.name)
                self?.symptoms[symptom.id.uuidString] = symptom
                try await self?.repository.editSymptom(symptom) // use function in the repository to create the symptom
            }
        }
    }
    
    // Return a formViewModel that has the necessary info for AnalysisView and has the option to edit if the symptom is active or not
    func createAnalysisViewModel(for symptom: Symptom) -> FormViewModel<Symptom> {
        return FormViewModel(initialValue: symptom) { [weak self] symptom in
            // Schedule notifications based on the input received from the user. When notification is empty, this function doesn't do anything
            NotificationManager.instance.scheduleNotifications(symptom.notification, symptom.name)
            // The next function updates the value of knowing if symptom is favorite or not
            self?.symptoms[symptom.id.uuidString] = symptom
            try await self?.repository.editSymptom(symptom) // use function in the repository to update the symptom
        }
    }
    
    func deleteSymptoms(at indices: IndexSet) {
        for index in indices {
            let symptom = sortedSymptoms[index]
            symptoms.removeValue(forKey: symptom.id.uuidString)
            // Delete the symptom in the repository. Use task to avoid making this function async
            Task {
                try await repository.deleteSymptom(symptom)
            }
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
                customPrint("[SymptomList] Cannot fetch symptoms: \(error)")
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

    // Dummy data for testing purposes.
    static func getDefaultSymptoms() -> [Symptom] {
        return [
            Symptom(name: "Peso", icon: "star.fill", description: "Este es un ejemplo de descripción que es bastante largo y se va haciendo mucho más largo para comprobar la funcionalidad.", isQuantitative: true, units: "kg", isFavorite: true, color: "#007AF", notification: ""),
            Symptom(name: "Cansancio", icon: "star.fill", description: "Este es un ejemplo de descripción corto.", isQuantitative: false, units: "", isFavorite: true, color: "#AF43EB", notification: "sssss"),
            Symptom(name: "Insomnio", icon: "star.fill", description: "Este es un ejemplo de descripción mediano, es decir, con esto está bien.", isQuantitative: true, units: "", isFavorite: true, color: "#D03A20", notification: ""),
            Symptom(name: "Estado cardíaco", icon: "star.fill", description: "Latidos por minuto.", isQuantitative: true, units: "BPM", isFavorite: true, color: "#86B953", notification: ""),
            Symptom(name: "Estado cardíaco 2", icon: "star.fill", description: "Latidos por minuto.", isQuantitative: true, units: "BPM", isFavorite: true, color: "#86B953", notification: "ssssss")
        ]
    }
}

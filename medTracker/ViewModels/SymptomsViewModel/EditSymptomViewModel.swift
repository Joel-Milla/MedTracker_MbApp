//
//  EditSymptomViewModel.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import Foundation
import SwiftUI

/**********************
 This class contains the methods to update a symptom
 **********************************/
@MainActor
class EditSymptomViewModel : ObservableObject {
    typealias Action = () async throws -> Void

    @Published var symptom: Symptom
    
    private let deleteSymptomAction: Action?
    private let updateAction: Action?
    private let deleteRegisterAction: Action?

    /**********************
     Important initialization methods
     **********************************/
    init(symptom: Symptom, deleteSymptomAction: Action?, updateAction: Action?, deleteRegisterAction: Action?) {
        self.symptom = symptom
        self.deleteSymptomAction = deleteSymptomAction
        self.updateAction = updateAction
        self.deleteRegisterAction = deleteRegisterAction
    }
    
    func updateValueActivo() {
        guard let updateAction = updateAction else {
            preconditionFailure("Cannot delete comment: no delete action provided")
        }
        Task {
            do {
                try await updateAction()
            } catch {
                customPrint("[EditSymptomViewModel] Error while updating symptom: \(error)")
            }
        }
    }
}

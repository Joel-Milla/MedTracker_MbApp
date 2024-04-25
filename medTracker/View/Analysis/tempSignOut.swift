//
//  tempSignOut.swift
//  MedTracker
//
//  Created by Joel Alejandro Milla Lopez on 24/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct tempSignOut: View {
    var body: some View {
        Button("Sign Out") {
            signOutUser()
        }
    }
    
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            // Handle the sign-out success, maybe navigate to the login screen
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Handle the error, maybe show an alert to the user
        }
    }
}

#Preview {
    tempSignOut()
}


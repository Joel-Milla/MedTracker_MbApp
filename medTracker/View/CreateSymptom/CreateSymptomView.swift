//
//  AddSymptomView2_0.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 24/03/24.
//

import SwiftUI

struct CreateSymptomView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var selectedOption: String = "Option 1"
    let options = ["Option 1", "Option 2", "Option 3"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.username)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section(header: Text("Settings")) {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember me")
                    }
                    
                    Picker("Options", selection: $selectedOption) {
                        ForEach(options, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.blue)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Professional Form")
        }
    }
}


#Preview {
    CreateSymptomView()
}

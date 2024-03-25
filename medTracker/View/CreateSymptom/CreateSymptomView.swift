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
    
    // Variables that hold values of the new symptom
    @State var selectedIcon: String = "heart"
    @State var selectedColor: Color = Color("blueGreen")
    @State var description: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre del Dato", text: $username)
                        .disableAutocorrection(true)
                        .textContentType(.username)
                    IconColorView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
                }
                // Description of the new symptom
                Section(header: Text("Descripción")) {
                    Text("Describe el dato")
                    TextEditor(text: $description)
                }
                // Choose the type of symptom
                Section(header: HelpView(title: "Tipo de dato")) {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember me")
                    }
                    
                    Picker("Options", selection: $selectedOption) {
                        ForEach(options, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("help")) {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember me")
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
            .navigationTitle("Crear Dato")
        }
    }
}


#Preview {
    CreateSymptomView()
}

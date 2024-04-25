//
//  CS_NameView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct CS_NameView: View {
    // Data variables
    @Binding var name: String
    @Binding var selectedIcon: String
    @Binding var colorToSave: String
    @State var selectedColor: Color = Color("blueGreen")
    // Sheet variables
    @State var showIconView = false

    var body: some View {
        // Name of the symptom
        TextField("Nombre del Dato", text: $name)
            .disableAutocorrection(true)
            .textContentType(.username)
            // limit the number of chars of the name
            .onChange(of: name) { newValue in
                if newValue.count > 27 {
                    name = String(newValue.prefix(27))
                }
            }

        // Picker to select the icon and color
        HStack {
            Text("Escoge un ícono:")
                .frame(maxWidth: .infinity, alignment: .leading) // make the text as large as possible and position it to the left
            HStack {
                // Button to show icon picker view
                Button(action: {
                    showIconView = true
                }, label: {
                    Image(systemName: selectedIcon)
                        .font(.title)
                        .foregroundStyle(selectedColor)
                })
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .fixedSize() // Limit the size to adjust layout
            }
            .frame(alignment: .trailing) // set the icons to the right side of the view
        }
        .sheet(isPresented: $showIconView, content: {
            IconPicker(selectedIcon: $selectedIcon)
        })
        // When the user changes the color, change the default color
        .onChange(of: selectedColor) { newValue in
            colorToSave = selectedColor.toHex()
        }
    }
}

#Preview {
    NavigationStack {
        @State var name: String = ""
        @State var selectedIcon: String = ""
        @State var colorToSave: String = "#009C8C"
        CS_NameView(name: $name, selectedIcon: $selectedIcon, colorToSave: $colorToSave)
    }
}

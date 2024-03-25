//
//  CS_NameView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct CS_NameView: View {
    // Data variables
    @State var name: String = ""
    @State var selectedIcon: String = "heart"
    @State var selectedColor: Color = Color("blueGreen")
    // Sheet variables
    @State var showIconView = false

    var body: some View {
        // Name of the symptom
        TextField("Nombre del Dato", text: $name)
            .disableAutocorrection(true)
            .textContentType(.username)
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
    }
}

#Preview {
    CS_NameView()
}

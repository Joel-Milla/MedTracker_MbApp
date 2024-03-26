//
//  IconView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct IconColorView: View {
    // Variables that hold the values of icon and color
    @Binding var selectedIcon : String
    @Binding var selectedColor : Color
    // View variables
    @State var showIconView = false
    
    var body: some View {
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
    NavigationStack {
        @State var selectedIcon : String = "heart"
        @State var selectedColor : Color = .blue

        IconColorView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
    }
}

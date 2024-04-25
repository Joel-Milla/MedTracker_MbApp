//
//  Button1MedTracker.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 06/11/23.
//


import Foundation
import SwiftUI

struct Button1MedTracker : ButtonStyle {
    var backgroundColor: Color
    
    init(backgroundColor: Color = Color("blueGreen")) {
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundStyle(.white)
            .font(.headline)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }}

//
//  GradientMedTracker.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 22/03/24.
//

import SwiftUI

// Main colors
extension Color {
    static let mainBlue = Color("mainBlue")
    static let blueGreen = Color("blueGreen")
}

// Create gradient style with original colors for Text
struct GradientStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 250) // set width of the gradient
            .background(LinearGradient(gradient: Gradient(colors: [.mainBlue, .blueGreen]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .shadow(radius: 5)
        // Add the next styles so the buttons are centered and without background inside a form element
            .frame(maxWidth: .infinity) // center the text
            .listRowBackground(Color.clear) // Makes the row background transparent
    }
}

// Create gradient style with original colors for Text
struct InputStyle: ViewModifier {
    func body(content: Content) -> some View {
        // Style for the input for having the borders with color, being gray and with spacing
        content
            .padding()
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.mainBlue, lineWidth: 1)
            )
    }
}

// Create a border color and a shadow around a view
// Style for the borders inside analysis view to have a border and a shadow
struct BorderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(.background)
                .shadow(color: Color.gray.opacity(0.5), radius: 5))
    }
}

// Extend View to create a custom modifier for any view
extension View {
    func gradientStyle() -> some View {
        self.modifier(GradientStyle())
    }
    func inputStyle() -> some View {
        self.modifier(InputStyle())
    }
    func borderStyle() -> some View {
        self.modifier(BorderStyle())
    }
}

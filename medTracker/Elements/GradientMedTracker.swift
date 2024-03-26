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
struct GradientTextStyle: ViewModifier {
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
    }
}

// Extend View to create a custom modifier for any view
extension View {
    func gradientTextStyle() -> some View {
        self.modifier(GradientTextStyle())
    }
}

//
//  PreviousRegistersView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 18/01/24.
//

import SwiftUI

struct PreviousRegistersView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}

#Preview {
    PreviousRegistersView()
}

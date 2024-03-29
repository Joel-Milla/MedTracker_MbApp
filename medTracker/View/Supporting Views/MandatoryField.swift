//
//  MandatoryField.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 29/03/24.
//

import SwiftUI

struct MandatoryField: View {
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
            Text("*")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    NavigationStack {
        let text = "Name"
        MandatoryField(text: text)
    }
}

//
//  ChangingText.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 29/03/24.
//

import SwiftUI

struct ChangingText: View {
    @Binding var state: HelperFunctions.State
    @State var title: String

    var body: some View {
        switch state {
        case .idle:
            Text(title)
        case .isLoading:
            ProgressView()
        case .successfullyCompleted:
            Text(title)
        }
    }
}

#Preview {
    NavigationStack {
        @State var state: HelperFunctions.State = .idle
        @State var title: String = "Hello"
        ChangingText(state: $state, title: title)
    }
}

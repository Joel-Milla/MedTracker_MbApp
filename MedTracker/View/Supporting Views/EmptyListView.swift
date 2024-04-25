//
//  EmptyListView.swift
//  medTracker
//
//  Created by Alumno on 20/11/23.
//

import SwiftUI

/**********************
 This view receives a title, message and an action and displays the view where its bein called. The action can be to activate a button, among other actions.
 **********************************/
struct EmptyListView: View {
    let title: String
    let message: String
    let nameButton: String
    var action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(message)
            if let action = action {
                Button(action: action) {
                    Text(nameButton)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary))
                }
                .padding(.top)
            }
        }
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding()
    }
}


struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            title: "Cannot Load Posts",
            message: "Something went wrong while loading posts. Please check your Internet connection.",
            nameButton: "Test",
            action: {}
        )
        EmptyListView(
            title: "No Posts",
            message: "There aren’t any posts yet.",
            nameButton: "Test"
        )
    }
}

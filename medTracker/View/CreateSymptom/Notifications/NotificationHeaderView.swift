//
//  NotificationHeaderView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct NotificationHeaderView: View {
    @Binding var allowNotifications: Bool
    @Binding var showNotificationView: Bool
    
    var body: some View {
        HStack {
            Text("Notificaciones")
                .frame(maxWidth: .infinity, alignment: .leading)
            if (allowNotifications) {
                Button(action: {
                    showNotificationView = true
                }, label: {
                    Text("Edit")
                        .textCase(.none)
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        @State var allowNotifications: Bool = true
        @State var showNotificationView: Bool = true
        NotificationHeaderView(allowNotifications: $allowNotifications, showNotificationView: $showNotificationView)
    }
}

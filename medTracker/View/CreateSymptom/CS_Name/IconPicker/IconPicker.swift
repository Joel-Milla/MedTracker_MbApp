//
//  IconPicker.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 25/03/24.
//

import SwiftUI

struct IconPicker: View {
    @ObservedObject var viewModel  = IconModel()
    @Binding var selectedIcon : String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5), content: {
                    ForEach(viewModel.iconFilter, id: \.self) { icon in
                        Image(systemName: icon)
                            .renderingMode(.template)
                            .font(.title)
                            .padding(10)
                            .onTapGesture {
                                selectedIcon = icon
                                dismiss()
                            }
                    }
                    .frame(width: 60, height: 60)
                    .background(.ultraThinMaterial, in: Circle())
                })
                .searchable(text: $viewModel.searchText)
            }
            .navigationTitle("Escoge tu ícono")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    NavigationStack {
        @State var selectedIcon : String = "placeholder"

        IconPicker(selectedIcon: $selectedIcon)
    }
}

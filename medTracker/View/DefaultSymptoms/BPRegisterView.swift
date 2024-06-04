//
//  BPRegisterView.swift
//  medTracker
//
//  Created by Joel Alejandro Milla Lopez on 27/05/24.
//

import SwiftUI

struct BPRegisterView: View {
    // Variable to make the request
    @StateObject var formViewModel: FormViewModel<(date: Date, systolicValue: Float, diastolicValue: Float, notes: String)>
    @State var symptom : Symptom
    
    // Variables that handle the input of the user for the register
    @State var systolic = ""
    @State var diastolic = ""
    @State var sliderValue: Float = 0.0
    
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    
    // Track the keyboard height
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(alignment: .leading) {
                    Text(symptom.name)
                        .font(.title)
                        .bold()
                    ZStack{
                        VStack(alignment: .leading) {
                            Text("Fecha de registro")
                                .padding(.horizontal)
                                .foregroundStyle(Color(uiColor: .systemGray))
                            DateSection(date: $formViewModel.value.date)
                                .padding()
                            bloodPressureInputSection
                                .padding(.horizontal)
                                
                        }
                        .padding(.vertical)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, 10)
                    )
                    .padding(.vertical)
                    ZStack{
                        VStack(alignment: .leading){
                            TextField("Agrega alguna nota", text: $formViewModel.value.notes, axis: .vertical)
                                .lineLimit(5)
                                .padding()
                                .frame(height: 100, alignment: .top)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, 10)
                    )
                    .shadow(radius: 10)
                    Button {
                        formViewModel.submit()
                    } label: {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $formViewModel.state, title: "Añadir registro")
                    }
                    .gradientStyle() // apply gradient style
                    
                }
                .padding()
                .padding(.bottom, keyboardHeight) // Add padding at the bottom
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                            self.keyboardHeight = keyboardFrame.height * 0.2
                        }
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                        self.keyboardHeight = 0
                    }
                }
            }
            // Set the values of systolic and diastolic
            .onChange(of: systolic) { newValue in
                formViewModel.value.systolicValue = Float(systolic) ?? -1000.99
            }
            .onChange(of: diastolic) { newValue in
                formViewModel.value.diastolicValue = Float(diastolic) ?? -1000.99
            }
            // Use onAppaer and onChange to set the value of amount
            .onAppear {
                // When symptom is quant, change the value of string into Float. If it is not possible then assign a float value where it will make an error to show the user that is not valid the amount
                // If sympomt is not quant, invert the value so it is shown correclty on the graphs
                formViewModel.value.systolicValue = Float(systolic) ?? -1000.99 // The default value is used to check if the input is invalid on later functions
                formViewModel.value.diastolicValue = Float(diastolic) ?? -1000.99 // The default value is used to check if the input is invalid on later functions
            }
            // MARK: The following edits are in charge of a good user experience that are consistent across sheets
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(formViewModel.submit)
            // Show alert to tell the user that there is an error
            .alert("Error al guardar datos", error: $formViewModel.error)
            // The next on change checks the state of the form submit and dismiss this view when it is completed succesfullly
            .onChange(of: formViewModel.state) { newValue in
                if (newValue == .successfullyCompleted ) {
                    dismiss()
                }
            }
            .toolbar {
                // Dismiss the view
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            }
            // MARK: Ending of consistent UI
        }
    }
    
    private var bloodPressureInputSection: some View {
        VStack(alignment: .leading) {
            Text("Ingresa el valor")
                .foregroundStyle(Color(uiColor: .systemGray))
                .padding(.bottom, 5)

            HStack {
                Image(systemName: symptom.icon)
                    .foregroundStyle(Color(hex: symptom.color))
                    .font(.title)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.gray.opacity(0.1)))

                TextField("Sistólica", text: $systolic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: systolic, perform: filterInput)

                Text("/")
                    .foregroundStyle(Color(hex: symptom.color))
                    .font(.headline)
                    .padding(.horizontal, 8)

                TextField("Diastólica", text: $diastolic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: diastolic, perform: filterInput)
            }
        }
    }
    
    private func filterInput(_ value: String) -> Void {
        let filtered = value.filter { "0123456789.-".contains($0) }
        if value != filtered {
            if value == systolic {
                systolic = filtered
            } else {
                diastolic = filtered
            }
        }
    }
    
}

//
//  RegistroDatos1.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 18/10/23.
//

import SwiftUI

struct RegisterSymptomView: View {
    // Variable to make the request
    @StateObject var formViewModel: FormViewModel<Register>
    @State var symptom : Symptom
    
    // Variables that handle the input of the user for the register
    @State var inputValue = ""
    @State var sliderValue: Float = 0.0
    
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    
    // Track the keyboard height
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(symptom.name)
                        .font(.title)
                        .bold()
                    ZStack {
                        VStack(alignment: .leading) {
                            Text("Fecha de registro")
                                .padding(.horizontal)
                                .foregroundStyle(Color(uiColor: .systemGray))
                            DateSection(date: $formViewModel.date)
                                .padding()
                            // Show different views depending if the symptoms is quantitative or not
                            if(!symptom.isQuantitative) {
                                CustomSlider(valueFinal: $sliderValue)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal, 5)
                                    .frame(height: 50)
                                    .padding(.vertical, 45)
                            } else {
                                HStack {
                                    Spacer()
                                    Text("Ingresa el valor")
                                        .foregroundStyle(Color(uiColor: .systemGray))
                                        .padding(.horizontal)
                                        .frame(alignment: .center)
                                    Spacer()
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                        .background(RoundedRectangle(cornerRadius: 20).fill(Color("mainWhite")))
                                        .frame(width: 250, height: 60)
                                    
                                    HStack {
                                        Image(systemName: symptom.icon)
                                            .foregroundColor(Color(hex: symptom.color))
                                            .font(.title)
                                            .padding(.leading, 50)
                                        TextField("", text: $inputValue, prompt: Text("Valor").foregroundColor(.gray))
                                            .font(.title2)
                                            .padding()
                                            .multilineTextAlignment(.leading)
                                            .keyboardType(.numberPad)
                                            .onChange(of: inputValue) { newValue in
                                                let filtered = newValue.filter { "0123456789.-".contains($0) }
                                                if filtered != newValue {
                                                    self.inputValue = filtered
                                                }
                                            }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, 10)
                    )
                    .padding(.vertical)
                    ZStack {
                        VStack(alignment: .leading) {
                            TextField("Agrega alguna nota", text: $formViewModel.notes, axis: .vertical)
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
                    .padding()
                    
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
            .onAppear {
                // When symptom is quant, change the value of string into Float. If it is not possible then assign a float value where it will make an error to show the user that is not valid the amount
                // If sympomt is not quant, invert the value so it is shown correctly on the graphs
                if (symptom.isQuantitative) {
                    formViewModel.amount = Float(inputValue) ?? -1000.99 // The default value is used to check if the input is invalid on later functions
                } else {
                    formViewModel.amount = invertSliderValue(sliderValue)
                }
            }
            .onChange(of: inputValue) { newValue in
                formViewModel.amount = Float(inputValue) ?? -1000.99
            }
            .onChange(of: sliderValue) { newValue in
                formViewModel.amount = invertSliderValue(sliderValue)
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
    
    // This function invert the value that the slider makes when the user selects something.
    // Need to invert the value so this can be shown correctly on the graphs
    func invertSliderValue(_ value: Float) -> Float {
        return 100 - value
    }
}


#Preview {
    NavigationStack {
        @State var formViewModel: FormViewModel<Register> = FormViewModel(initialValue: Register(idSymptom: "1"), action: {_ in })
        @State var symptom = Symptom(name: "Hello", icon: "heart", description: "wow", isQuantitative: true, units: "kg", isFavorite: true, color: "#000", notification: "1234")
        RegisterSymptomView(formViewModel: formViewModel, symptom: symptom)
    }
}

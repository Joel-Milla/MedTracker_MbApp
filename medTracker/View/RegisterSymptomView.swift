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

    // Variable that handle the input of the user for the register
    @State var inputValue = ""
    
    // Dismiss the view when no longer needed
    @Environment(\.dismiss) var dismiss
    
    @State private var notificacionesActivas = false
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    Text(symptom.nombre)
                        .font(.title)
                        .bold()
                    ZStack{
                        VStack(alignment: .leading){
                            Text("Fecha de registro")
                                .padding(.horizontal)
                                .foregroundStyle(Color(uiColor: .systemGray))
                            DateSection(date: $formViewModel.fecha)
                                .padding()
                            // Show different views depending if the symptoms is quantitative or not
                            if(!symptom.cuantitativo){
                                CustomSlider(valueFinal: $formViewModel.cantidad)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal, 5)
                                    .frame(height: geometry.size.height * 0.06)
                                    .padding(.vertical, 35)
                            }
                            else{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                        .background(RoundedRectangle(cornerRadius: 20).fill(Color("mainWhite")))
                                        .frame(width: geometry.size.width * 0.63, height: geometry.size.height * 0.1)
                                    
                                    HStack {
                                        Image(systemName: symptom.icon)
                                            .foregroundColor(Color(hex: symptom.color))
                                            .font(.title)
                                            .padding(.leading, geometry.size.width * 0.25)
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
                            .padding(.horizontal, geometry.size.width * 0.01)
                    )
                    .padding(.vertical)
                    ZStack{
                        VStack(alignment: .leading){
                            TextField("Agrega alguna nota", text: $formViewModel.notas, axis: .vertical)
                                .lineLimit(5)
                                .padding()
                                .frame(height: geometry.size.height / 6, alignment: .top)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: symptom.color), lineWidth: 2)
                            .padding(.horizontal, geometry.size.width * 0.01)
                    )
                    .shadow(radius: 10)
                    Button{
                        // When symptom is quant, change the value of string into Float
                        if (symptom.cuantitativo) {
                            formViewModel.cantidad = Float(inputValue) ?? -1000.99
                        }
                        formViewModel.submit()
                    } label: {
                        Label("Añadir registro", systemImage: "cross.circle.fill")
                    }
                    .buttonStyle(Button1MedTracker(backgroundColor: Color(hex: symptom.color)))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                    
                }
                .padding()
            }
            // MARK: The following edits are in charge of a good user experience
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
            // MARK: Ending of general user experience
            .toolbar {
                // Dismiss the view
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
                
                // Change value of notification
                ToolbarItem(placement: .navigationBarTrailing) {
                    //MARK: El boton no sirve ********************
                    Button {
                        notificacionesActivas.toggle()
                    } label: {
                        Image(systemName: notificacionesActivas ? "bell.fill" : "bell.slash")
                    }
                    //MARK: El boton no sirve ********************
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        @State var formViewModel: FormViewModel<Register> = FormViewModel(initialValue: Register(idSymptom: "1"), action: {_ in })
        @State var symptom = Symptom(nombre: "Hello", icon: "heart", description: "wow", cuantitativo: true, unidades: "kg", activo: true, color: "#000", notificacion: "1234")
        RegisterSymptomView(formViewModel: formViewModel, symptom: symptom)
    }
}


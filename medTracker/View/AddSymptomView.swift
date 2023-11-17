//
//  newSymptom.swift
//  medTracker
//
//  Created by Alumno on 26/10/23.
//

import SwiftUI
import SegmentedPicker

struct AddSymptomView: View {
    @State var nombreSintoma = ""
    @State var descripcion = ""
    @State private var colorSymptom = Color.blue
    @State private var colorString = ""
    @State var notificaciones = false
    @State var selectedIndex: Int?
    var cada_cuanto = ["Todos los días", "Cada semana", "Una vez al mes"]
    @State var notificaciones_seleccion = "Todos los días"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    TextField("Nombre del síntoma", text: $nombreSintoma, axis : .vertical)
                        .font(.system(size: 28))
                        .lineSpacing(4)
                        .foregroundColor(colorSymptom)
                    
                    ColorPicker("", selection: $colorSymptom)
                        .labelsHidden()
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                Text("Descripción")
                    .font(.system(size: 24))
                    .padding(.top, 22)
                
                TextField("Escriba la descripción del síntoma", text: $descripcion, axis : .vertical)
                    .font(.system(size: 18))
                    .textFieldStyle(.roundedBorder)
                    .lineSpacing(4)
                    .padding(.trailing, 20)
                    .foregroundColor(colorSymptom)
                    .disableAutocorrection(true)
                
                Text("Tipo")
                    .font(.system(size: 24))
                    .padding(.top, 22)
                
                HStack {
                    Spacer()
                    SegmentedPicker(
                        ["Cuantitativo", "Cualitativo"],
                        selectedIndex: Binding(
                            get: { selectedIndex },
                            set: { selectedIndex = $0 }),
                        content: { item, isSelected in
                            Text(item)
                                .foregroundColor(isSelected ? Color.white : Color.black )
                                .padding(.horizontal, 45)
                                .padding(.vertical, 8)
                        },
                        selection: {
                            Capsule()
                                .fill(colorSymptom)
                        })
                    .animation(.easeInOut(duration: 0.3))
                    Spacer()
                }
                
                Toggle("Recibir notificaciones", isOn: $notificaciones)
                    .tint(colorSymptom)
                    .padding(.trailing, 20)
                    .padding(.top, 40)
                    .font(.system(size: 24))
                
                Picker("Quiero recibirlas:", selection: $notificaciones_seleccion) {
                    ForEach(cada_cuanto, id: \.self) {
                        Text($0)
                            //.foregroundColor(notificaciones ? colorSymptom : Color.gray)
                    }
                }
                .pickerStyle(.navigationLink)
                .disabled(!notificaciones ? true : false)
                .foregroundColor(notificaciones ? colorSymptom : Color.gray)
                .padding(.trailing, 20)
                .font(.system(size: 18))
                
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Label("Añadir síntoma", systemImage: "cross.circle.fill")
                    }
                    .buttonStyle(Button1MedTracker(backgroundColor: colorSymptom))
                    .padding(.top, 50)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 20)
            .background(Color("mainWhite"))
            .navigationTitle("Nuevo síntoma")
        }
        .onAppear {
            // Initialize hexString with the initial color
            colorString = hexString(from: colorSymptom)
        }
        .onChange(of: colorSymptom) { newColor in
            // Update hexString when the color changes
            colorString = hexString(from: newColor)
        }
    }
    
    func hexString(from color: Color) -> String {
            // Convert SwiftUI Color to UIColor
            let uiColor = UIColor(color)

            // Get the RGBA components
            guard let components = uiColor.cgColor.components else {
                return ""
            }

            let red = Float(components[0])
            let green = Float(components[1])
            let blue = Float(components[2])

            // Convert the components to HEX
            let hexString = String(
                format: "#%02lX%02lX%02lX",
                lroundf(red * 255),
                lroundf(green * 255),
                lroundf(blue * 255)
            )

            return hexString
    }
}

struct newSymptom_Previews: PreviewProvider {
    static var previews: some View {
        AddSymptomView()
    }
}
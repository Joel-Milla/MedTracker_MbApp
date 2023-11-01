//
//  RegistroDatos1.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 18/10/23.
//

import SwiftUI


//usar contentview??
//cambiar color de contenttitle?

struct RegistroDatos1: View {
    @State var metricsString = ""
    @State private var date = Date.now
    @State var sliderOrTF : Bool = true
    @State var notes = ""
    var dummySymptom = "Migraña"
    @State var metric: Double = 5
    //let mainWhite = Color
    var body: some View {
        NavigationStack(){
            ZStack {
                Color("mainWhite").ignoresSafeArea()
                VStack() {
                    Text(dummySymptom)
                        .font(.title)
                        .foregroundStyle(Color("secondaryBlue"))
                        .bold()
                        .padding(.horizontal, -179)
                    DatePicker("Fecha registro", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal,3)
                        .foregroundColor(Color("secondaryBlue")) // sale identico??
                        .accentColor(Color("mainBlue"))
                        .bold()
                    //Text("La fecha es \(date.formatted(date: .numeric, time: .shortened))")
                    if(sliderOrTF){
                        Text("Califica cómo te sientes")
                        Slider(value: $metric, in: 0...10)
                            .padding()
                            .tint(getColor())
                    }
                    else{
                        Text("Ingresa el valor")
                        TextField("Valor", text: $metricsString)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding(10)
                        .cornerRadius(20)
                                .shadow(color: .gray, radius: 2)
                    Spacer()
                    Button{
                    }label:{
                        Image("boton_anadirReg")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Spacer()
                .navigationTitle("Agregar síntoma")
            }
            .toolbar{
                Button{
                    
                }label:{
                    Text("Done")
                }
            }
        }
    }
    // otra forma de hacer esto?
    func getColor()->Color{
        if(metric < 4){
            return Color.green
        }
        else if(metric >= 4 && metric < 7){
            return Color.yellow
        }
        else if(metric >= 7){
            return Color.red
        }
        else{
            return Color("mainBlue")
        }
    }
}

#Preview {
    RegistroDatos1()
}

/*
 NOTAS:
 COMO CAMBIAR SLIDER THUMBNAIL
 QUE ES INIT??
 pongo dos imagenes en los extremos de la barra?
 QUE PONGO DE BOTON?
 HAY FORMA DE CAMBIAR EL COLOR DEL PICKER DE FECHA?
 AÑADIR LISTA DE UNIDADES
 HACER CLASES
 MEJORAR SISTEMA DE NOTAS, NO PUEDO HACER MAS GRANDE EL TEXTFIELD??
 Siento que hay mucho espacio
 Mejor tipo de animacion... usar sheet? o cambiar con transicion
 Investigar elementos interesantes
 Hacer otra vista para agregar notas??
 Agregar gradient
 */

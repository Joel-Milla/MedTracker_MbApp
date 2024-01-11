//
//  AnalysisDoctorView.swift
//  medTracker
//
//  Created by Alumno on 26/11/23.
//

import SwiftUI
import Charts

/**********************
 This view shows an analysis of the symptoms that are being tracked by the patient.
 **********************************/
struct AnalysisDoctorView: View {
    let patient: Patient
    @State var patientsData: PatientsData
    @State private var isShowingActivityView = false
    @State private var activityItems: [Any] = []
    
    init(patient: Patient) {
        self.patient = patient
        _patientsData = State(initialValue: PatientsData(email: patient.email))
    }
    
    var body: some View {
        ZStack {
            switch patientsData.state {
            case .complete:
                // If there are no symptoms bein checked, then show this view.
                if patientsData.symptoms.isEmpty {
                    //The action serves as a trigger to show a sheet of the view to add new symptoms.
                    EmptyListView(
                        title: "No hay sintomas registrados",
                        message: "El paciente no ha agregado ningun sintoma.",
                        nameButton: "Agregar Sintoma"
                    )
                }
                // If there are symptoms being checked then show this view.
                else {
                    VStack {
                        // Show a tab for each symptom that is active.
                        TabView {
                            ForEach(patientsData.symptoms.filter { $0.activo == true }, id: \.id) { symptom in
                                AnalysisPatientView(symptom: symptom, allRegisters: patientsData.registers.filter({ $0.idSymptom == symptom.id }))
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        
                        Spacer(minLength: 10)
                    }
                    .background(Color("mainWhite"))
                    .navigationTitle(patient.name)
                    .toolbar {
                        // Button to traverse to EditSymptomView.
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                if let url = exportCSV() {
                                    activityItems = [url]
                                    isShowingActivityView = true
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
            case .isLoading:
                ProgressView()
            }
        }
    }
    
    func exportCSV()-> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let fileName = "Datos.csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        var csvText = "Nombre del Dato,Fecha,Cantidad,Notas\n"
        let sortedRegs = patientsData.registers.sorted(by: {$0.idSymptom > $1.idSymptom})
        for register in sortedRegs {
            let fechaStr = formatter.string(from:register.fecha)
            if(getSymptomIsActive(register: register)){
                let newLine = "\(getSymptomOfName(register: register)),\(fechaStr),\(register.cantidad),\(register.notas)\n"
                csvText.append(contentsOf: newLine)
            }
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootViewController = windowScene.windows.first?.rootViewController {
                    let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error al escribir el archivo CSV: \(error)")
        }
        return path
    }
    
    func getSymptomIsActive(register: Register) -> Bool {
        if let symptom = patientsData.symptoms.first(where: { $0.id == register.idSymptom }) {
            return symptom.activo
        }
        return false
    }
    
    func getSymptomOfName(register: Register) -> String {
        if let symptom = patientsData.symptoms.first(where: { $0.id == register.idSymptom }) {
            return symptom.nombre
        }
        return "Unknown Symptom"
    }
}

struct AnalysisPatientView: View {
    @State var symptom: Symptom
    @State var allRegisters: [Register]
    @State private var muestraRegisterSymptomView = false
    @State var currentTab = "Semana"
    @State var registers : [Register] = []
    
    var body: some View {
        let colorSintoma = Color(hex: symptom.color)
        VStack(alignment: .leading) {
            Text(symptom.nombre)
                .foregroundColor(colorSintoma)
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            Text("Descripción: ")
                .font(.system(size: 24))
                .padding(.top, 5)
            
            Text("\(symptom.description)")
                .padding(.trailing, 20)
                .foregroundColor(colorSintoma)
                .lineSpacing(4)
                .font(.system(size: 20))
                .frame(height: 120, alignment: .top)
            
            // The next if/else statement check for each symptoms if there is a data, if not then the if will run and notify the user that need to add a value to the symptom.
            if allRegisters.isEmpty {
                EmptyListView(
                    title: "No hay registros de este sintoma",
                    message: "El paciente no ha agregado ningún registro.",
                    nameButton: "Agregar Registro"
                )
                //The else statement runs if there is already data associated with the symptom.
            } else {
                Text("Últimos registros:")
                    .font(.system(size: 24))
                
                VStack (alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Registros")
                            .fontWeight(.semibold)
                            .foregroundColor(colorSintoma)
                        
                        Picker("", selection: $currentTab) {
                            Text("Semana")
                                .tag("Semana")
                            Text("Mes")
                                .tag("Mes")
                            Text("Todos")
                                .tag("Todos")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 60)
                    }
                    .padding(.bottom, symptom.cuantitativo ? 0 : 35)
                    
                    if symptom.cuantitativo {
                        ChartCuantitativa(filteredRegisters: registers)
                    } else {
                        ChartCualitativa(filteredRegisters: registers)
                    }
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("mainWhite").shadow(.drop(color: .primary,radius: 1)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(hex: symptom.color), lineWidth: 1) // Adjust color and lineWidth as needed
                        )
                }
                .padding(.trailing, 20)
                
                Spacer(minLength: 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 20)
        /*.overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(colorSintoma)
        }*/
        .onAppear() {
            registers = allRegisters
            currentTab = "Semana"
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            registers = allRegisters.filter { $0.fecha > oneWeekAgo }
        }
        .onChange(of: currentTab) { newValue in
            registers = allRegisters
            if newValue == "Semana" {
                let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                registers = allRegisters.filter { $0.fecha > oneWeekAgo }
            } else if newValue == "Mes" {
                let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                registers = allRegisters.filter { $0.fecha > oneMonthAgo }
            }
        }
    }


    
    @ViewBuilder
    func ChartCuantitativa(filteredRegisters: [Register]) -> some View {
        
        let registers = filteredRegisters.sorted { $0.fecha < $1.fecha }
        
        let spm = operaciones(registers: registers)
        Text("Prom: \(spm[0].stringFormat)  Max: \(spm[1].stringFormat)  Min: \(spm[2].stringFormat)")
            .font(.system(size: 18).bold())
        //.foregroundColor(Color(hex: symptom.color))
        
        let min = spm[2]*0.8
        let max = spm[1]*1.2
        
        Chart {
            ForEach(registers, id:\.self) { register in
                LineMark (
                    x: .value("Día", register.fecha, unit: .day),
                    y: .value("CANTIDAD", register.cantidad)//register.animacion ? register.cantidad : 0)
                )
                .foregroundStyle(Color(hex: symptom.color))
                .interpolationMethod(.catmullRom)
                
                AreaMark (
                    x: .value("Día", register.fecha, unit: .day),
                    yStart: .value("minY", min),
                    yEnd: .value("maxY", register.cantidad)
                    //y: .range(min...register.cantidad)//register.animacion ? register.cantidad : 0)
                )
                .foregroundStyle(Color(hex: symptom.color).opacity(0.1))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYScale(domain: min <= max ? min...max : 0...100)
        .frame(height: 250)
        .background(Color("mainWhite"))
        
    }
    
    @ViewBuilder
    func ChartCualitativa(filteredRegisters: [Register]) -> some View {
        let registers = filteredRegisters.sorted { $0.fecha < $1.fecha }
        
        let yAxisLabels: [ImageYAxisLabel] = [
                ImageYAxisLabel(id: 10, image: "sadder_face"),
                ImageYAxisLabel(id: 30, image: "sad_face"),
                ImageYAxisLabel(id: 50, image: "normal_face"),
                ImageYAxisLabel(id: 70, image: "va_test"),
                ImageYAxisLabel(id: 90, image: "happier_face")
            ]
        
            Chart {
                ForEach(registers, id:\.self) { register in
                    LineMark (
                        x: .value("Día", register.fecha, unit: .day),
                        y: .value("CANTIDAD", register.cantidad)
                    )
                    .foregroundStyle(Color(hex: symptom.color))
                    .interpolationMethod(.catmullRom)

                    AreaMark (
                        x: .value("Día", register.fecha, unit: .day),
                        yStart: .value("minY", 0),
                        yEnd: .value("maxY", register.cantidad)
                    )
                    .foregroundStyle(Color(hex: symptom.color).opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 6))
            }
            .overlay(
                customYAxisScale(yAxisLabels: yAxisLabels)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            )
            .frame(height: 250)
            .background(Color("mainWhite"))
        }
    
    private func customYAxisScale(yAxisLabels: [ImageYAxisLabel]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(yAxisLabels) { label in
                Image(label.image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 6)
            }
        }
        .foregroundColor(.clear)
        .padding(.top, 5)
    }
    
    func operaciones(registers: [Register]) -> [Float] {
        var operacionesList : [Float] = [0,0,Float.greatestFiniteMagnitude]
        
        for item in registers {
            operacionesList[0] = operacionesList[0] + item.cantidad
            if operacionesList[1] < item.cantidad {
                operacionesList[1] = item.cantidad
            }
            if operacionesList[2] > item.cantidad {
                operacionesList[2] = item.cantidad
            }
        }
        operacionesList[0] = operacionesList[0] / Float(registers.count)
        
        return operacionesList
    }
}

struct ImageYAxisLabel: Identifiable {
    var id: Int
    var image: String
}

struct AnalysisDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisDoctorView(patient: Patient(email: "", name: ""))
    }
}

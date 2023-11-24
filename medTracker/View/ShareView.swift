//
//  ShareView.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 20/11/23.
//

import SwiftUI

//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    let applicationActivities: [UIActivity]? = nil
//    let onComplete: (Bool) -> Void
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//        controller.completionWithItemsHandler = { (_, completed, _, _) in
//            onComplete(completed)
//        }
//        return controller
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No es necesario actualizar el UIActivityViewController.
//    }
//}

struct ShareView: View {
    @ObservedObject var listaDatos : SymptomList
    @ObservedObject var registers : RegisterList
    // ... tus propiedades ...
    
    @State private var isShowingActivityView = false
    @State private var activityItems: [Any] = []
    
    var body: some View {
        Section {
            Button("Exportar como CSV") {
                if let url = exportCSV() {
                    activityItems = [url]
                    isShowingActivityView = true
                }
            }
        }
        .sheet(isPresented: $isShowingActivityView) {
            ActivityView(activityItems: activityItems, onComplete: { completed in
                isShowingActivityView = false
                // Aquí puedes manejar el resultado de la acción de compartir.
            })
        }
    }
    func exportCSV()-> URL? {
        let fileName = "Datos.csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        var csvText = "Nombre del Dato,Fecha,Cantidad,Notas\n"
        let sortedRegs = registers.registers.sorted(by: {$0.idSymptom > $1.idSymptom})
        for register in sortedRegs {
            let newLine = "\(getSymptomName(register: register)),\(register.fecha),\(register.cantidad),\(register.notas)\n"
            csvText.append(contentsOf: newLine)
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

}
func iterate (registers : RegisterList)->[String]{
    var csvInfo = [String]()
    csvInfo.reserveCapacity(registers.registers.count)
    for (register) in registers.registers{
        let stringAppend = "\(register.fecha), \(String(register.cantidad)), \(register.notas)"
            csvInfo.append(stringAppend)
        }
        return csvInfo
    }
//func getName(register : Register)->String{
//    @ObservedObject var listaDatos = SymptomList()
//    return listaDatos.returnName(id: register.idSymptom)
//}

struct share_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(listaDatos: SymptomList(), registers: RegisterList())
    }
}
struct ShareInfo{
    
}

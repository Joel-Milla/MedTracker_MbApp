//
//  DateSection.swift
//  MedTrackerTests
//
//  Created by Sebastian Presno Alvarado on 22/03/24.
//

import Foundation
import SwiftUI

struct DateSection : View {
    @State var date : Date
    @State var hour : Date
    var body: some View{
        VStack{
            HStack{
                Text("Día")
                Spacer()
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.automatic)
            }
            Divider()
            HStack{
                Text("Hora")
                Spacer()
                DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.automatic)
            }
        }
    }
}

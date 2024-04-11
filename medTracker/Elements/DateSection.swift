//
//  DateSection.swift
//  MedTrackerTests
//
//  Created by Sebastian Presno Alvarado on 22/03/24.
//

import Foundation
import SwiftUI

struct DateSection : View {
    @Binding var date : Date

    var body: some View{
        VStack{
            HStack{
                Text("Día")
                Spacer()
                DatePicker("", selection: $date, in: HelperFunctions.dateRange, displayedComponents: [.date])
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

#Preview {
    NavigationStack {
        @State var date = Date.now
        DateSection(date: $date)
    }
}

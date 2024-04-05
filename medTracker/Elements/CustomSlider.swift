//
//  TestSlider.swift
//  medTracker
//
//  Created by Sebastian Presno Alvarado on 07/11/23.
//

import Foundation
import SwiftUI

struct CustomSlider: View {
    
    @Binding var valueFinal: Double
    var valor : Double = 0.155
    @State var lastCoordinateValue: CGFloat = 0
    @State var value : Double = 0
    var body: some View {
        GeometryReader { gr in
            let cursorSize = gr.size.height
            let radius = gr.size.height * 0.5
            let minValue = 0.0
            let maxValue = gr.size.width * 0.87
            VStack(alignment: .leading){
                Text("Desliza dependiendo de cómo te sientes")
                    .foregroundStyle(Color(uiColor: .systemGray))
                    .padding(.horizontal)
                ZStack {
                    RoundedRectangle (cornerRadius: radius)
                        .foregroundColor (getColor())
                    HStack {
                        Image(getImage())
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            //.foregroundStyle(.white)
                            .frame (width: cursorSize , height: cursorSize)
                            .offset (x: self.value + 3)
                            .gesture (
                                DragGesture (minimumDistance: 0)
                                    .onChanged { v in
                                        if (abs(v.translation.width) < 0.1) {
                                            self.lastCoordinateValue = self.value
                                        }
                                        if (v.translation.width > 0 && self.value <= maxValue) {
                                            self.value = min (maxValue, self.lastCoordinateValue + v.translation.width)
                                            valueFinal = getValue(maxValue: maxValue)
                                        } else{
                                            self.value = max (minValue, self.lastCoordinateValue + v.translation.width)
                                            valueFinal = getValue(maxValue: maxValue)
                                        }
                                        if(self.value >= maxValue){
                                            self.value = maxValue
                                            valueFinal = 100;
                                        }
                                    }
                            )
//                            Image(getImage())
//                                .resizable()
//                                .scaledToFit()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: cursorSize * 1.3, height: cursorSize * 1.3)
//                                .offset(x:self.value - gr.size.width * valor + 7.5)
//                                .gesture (
//                                    DragGesture (minimumDistance: 0)
//                                        .onChanged { v in
//                                            if (abs(v.translation.width) < 0.1) {
//                                                self.lastCoordinateValue = self.value
//                                            }
//                                            if (v.translation.width > 0 && self.value <= maxValue) {
//                                                self.value = min (maxValue, self.lastCoordinateValue + v.translation.width)
//                                                valueFinal = getValue(maxValue: maxValue)
//                                            } else{
//                                                self.value = max (minValue, self.lastCoordinateValue + v.translation.width)
//                                                valueFinal = getValue(maxValue: maxValue)
//                                            }
//                                            if(self.value >= maxValue){
//                                                self.value = maxValue
//                                                valueFinal = 100;
//                                            }
//                                        }
//                                )
                        //                    Text("\(valueFinal,  specifier: "%.2F")")
                        //                    Text("\(value,  specifier: "%.2F")")
                        Spacer()
                    }
                }
                .shadow(radius: 5)
            }
        }
    }
    
    func getColor() -> Color {
        if(valueFinal < 20){
            return Color("green_MT")
        }
        else if(valueFinal >= 20 && valueFinal < 80){
            if(valueFinal < 40){
                return Color("yellowgreen_MT")
            }
            else if(valueFinal >= 40 && valueFinal < 60){
                return Color("yellow_MT")
            }
            else if(valueFinal >= 60){
                return Color("orange_MT")
            }
        }
        else if(valueFinal >= 80){
            return Color("red_MT")
        }
        else{
            return Color("mainBlue")
        }
        return Color(.white)
    }
    func getValue(maxValue: Double)->Double{
        return(100 * value) / maxValue
    }
    func getImage()->String{
        if(valueFinal < 20){
            return "happier_face"
        }
        else if(valueFinal >= 20 && valueFinal < 80){
            if(valueFinal < 40){
                return "happy_face"
            }
            else if(valueFinal >= 40 && valueFinal < 60){
                return "normal_face"
            }
            else if(valueFinal >= 60){
                return "sad_face"
            }
        }
        else if(valueFinal >= 80){
            return "sadder_face"
        }
        else{
            return ""
        }
        return ""
    }
    
}

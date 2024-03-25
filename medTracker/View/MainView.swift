//
//  ContentView.swift
//  bottomTabBar
//
//  Created by Alumno on 16/10/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var symptoms: SymptomList
    @StateObject var registers: RegisterList
    @StateObject var user: UserModel
    
    var body: some View {
//        TabView (selection: $currentTab) {
//            AnalysisView(symptoms: symptoms, registers: registers)
//                .tag(Tab.Analisis)
//            HomeView(symptoms: symptoms, registers: registers)
//                .tag(Tab.Inicio)
//            ProfileView(user: user, symptoms: symptoms, createAction: user.makeCreateAction(), createAction2: symptoms.makeCreateAction())
//                .tag(Tab.Perfil)
//        }
        TabView {
            NavigationStack {
                HomeView(symptoms: symptoms, registers: registers)
            }
            .tabItem {
                Label("Inicio", systemImage: "house")
            }
            NavigationStack {
                ProfileView(user: user, symptoms: symptoms, createAction: user.makeCreateAction(), createAction2: symptoms.makeCreateAction())
            }
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
        }
        .accentColor(Color("blueGreen"))
        .navigationBarBackButtonHidden(true)
    }
}

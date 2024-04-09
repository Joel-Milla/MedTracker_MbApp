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
        TabView {
            // Default view that shows the list of symptoms
            NavigationStack {
                HomeView(symptoms: symptoms, registers: registers)
            }
            .tabItem {
                Label("Inicio", systemImage: "house")
            }
            // View for the users to see their information and edit it.
            NavigationStack {
                ProfileView(user: user, symptoms: symptoms, createAction: user.makeCreateAction(), createAction2: {_ in })
            }
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
        }
        .accentColor(Color("blueGreen"))
        .navigationBarBackButtonHidden(true) // Do not show the option to go back
    }
}

#Preview {
    NavigationStack {
        @State var repository = Repository(user: User(id: "3zPDb70ofQQHximl1NXwPMgIhMR2", rol: "Paciente", email: "joel@mail.com", phone: "", name: "Joel", clinicalHistory: "", sex: "", birthdate: Date.now, height: "", doctors: ["doc@mail.com"]))
        
        @State var symptoms: SymptomList = SymptomList(repository: repository)
        @State var registers: RegisterList = RegisterList(repository: repository)
        @State var user: UserModel = UserModel(repository: repository)
        MainView(symptoms: symptoms, registers: registers, user: user)
    }
}

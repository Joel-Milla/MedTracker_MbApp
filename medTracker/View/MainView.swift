//
//  ContentView.swift
//  bottomTabBar
//
//  Created by Alumno on 16/10/23.
//  

import SwiftUI

struct MainView: View {
    @StateObject var symptoms = SymptomList()
    @StateObject var registers = RegisterList()
    @State private var muestraEditarSintomas = false
    @StateObject var user = UserModel()
    @State var currentTab: Tab = .Inicio
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    @Namespace var animation
    var body: some View {
        TabView (selection: $currentTab) {
            AnalysisView(listSymp: symptoms, registers: registers)
                .tag(Tab.Analisis)
            HomeView(listaDatos: symptoms, registers: registers)
                .tag(Tab.Inicio)
            ProfileView(user: user, symptoms: symptoms, createAction: user.makeCreateAction(), createAction2: symptoms.makeCreateAction())
                .tag(Tab.Perfil)
        }
        .overlay(
            HStack (spacing: 0){
                ForEach(Tab.allCases, id :\.rawValue) { tab in
                    TabButton(tab: tab)
                }
                .padding(.vertical)
                .padding(.bottom, getSafeArea().bottom == 0 ? 5 :
                            (getSafeArea().bottom))
                .background(.secondary)
            }
            ,
            alignment: .bottom
        ).ignoresSafeArea(.all, edges: .bottom)
    }
    
    func TabButton(tab: Tab) -> some View {
        GeometryReader { proxy in
            
            Button(action: {
                withAnimation(.spring()) {
                    currentTab = tab
                }
            }, label: {
                VStack(spacing: 0) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == tab ? .white : .black)
                        .padding(currentTab == tab ? 15 : 0)
                        .background(
                            ZStack {
                                if currentTab == tab {
                                    MaterialEffect(style: .light)
                                        .background(Color("blueGreen"))
                                        .clipShape(Circle())
                                    //.matchedGeometryEffect(id: "TAB", in: animation)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .offset(y: currentTab == tab ? -35 : 0)
                    
                    Text(tab.tabName)
                        .foregroundColor(Color.black)
                        .font(.system(size: 16))
                        .padding(.top, 65)
                        .offset(y: currentTab == tab ? -95 : -60)
                }
            })
        }
        .frame(height: 25)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

enum Tab: String, CaseIterable {
    case Analisis = "chart.xyaxis.line"
    case Inicio = "house"
    case Perfil = "person"
    
    var tabName : String {
        switch self {
        case .Analisis:
            return "Análisis"
        case .Inicio:
            return "Inicio"
        case .Perfil:
            return "Perfil"
        }
    }
}

extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let pantalla = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = pantalla.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
}

struct MaterialEffect : UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


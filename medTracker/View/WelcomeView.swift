//
//  Bienvenida.swift
//  medTracker
//
//  Created by Alumno on 09/11/23.
//

import SwiftUI

/**********************
 This view only displays a welcome message and two buttons to log in or register.
 **********************************/
struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainWhite")
                    .ignoresSafeArea()
                VStack{
                    if colorScheme == .light{
                        Image("logoV")
                            .resizable()
                            .imageScale(.small)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                    }
                    else{
                        Image("logoDarkMode")
                            .resizable()
                            .imageScale(.small)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                    }
                    NavigationLink {
                        LogInView(signInModel: authViewModel.makeSignInViewModel())
                    } label: {
                        Text("Iniciar Sesión")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    NavigationLink {
                        RegisterView(createAccountModel: authViewModel.makeCreateAccountViewModel())
                    } label: {
                        Text("Registrarse")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                }
                
            }
        }
    }
}

struct Bienvenida_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
